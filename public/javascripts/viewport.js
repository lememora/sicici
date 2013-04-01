Ext.namespace('app.viewport.data');

app.viewport.data.searching = false;
app.viewport.data.statusParams = new Object();


Ext.namespace('app.viewport.layout');

app.viewport.layout.usernamePanel = new Ext.Panel(
{
  id: 'viewport-username-panel',
  layout: 'fit',
  region: 'center',
  border: false,
  html: "<span></span>"
});

app.viewport.layout.searchInput = new Ext.form.TextField(
{
  id: 'viewport-search-input',
  anchor: '100%',
  height: 26,
  enableKeyEvents: true,
  selectOnFocus: true,
  emptyText: 'pesquisar'
});

app.viewport.layout.searchInput.addListener('specialKey', function(f, e)
{
  if(e.getKey() == Ext.EventObject.ENTER)
  {
    app.viewport.action.expandSearch();
    f.blur();
  }
  else if(e.getKey() == Ext.EventObject.TAB ||
          e.getKey() == Ext.EventObject.DOWN)
  {
    f.blur();
    if(f.getValue().length > 0)
    {
      var searchGrid = app.viewport.layout.searchGrid;
      searchGrid.getSelectionModel().selectFirstRow();
      searchGrid.getView().focusEl.focus();
    }
  }
  else if(e.getKey() == Ext.EventObject.ESC)
  {
    f.setValue('');
    f.blur();
    app.viewport.action.searchResult();
  }
});

app.viewport.layout.searchInput.on('keydown', function(f, e)
{
  keyNumber = parseInt(e.getKey());
  if((keyNumber == 8) ||
     (keyNumber > 47 && keyNumber < 58) ||
     (keyNumber > 64 && keyNumber < 91))
  {
    app.viewport.action.searchResult.defer(50);
  }
});

app.viewport.layout.searchInput.on('focus', function()
{
  app.viewport.action.searchResult();
});

app.viewport.layout.searchExpandButton = new Ext.Button(
{
  id: 'viewport-search-expand-button',
  text: "Buscar",
  icon: 'images/icons/arrow_left.png'
});

app.viewport.layout.searchExpandButton.on('click', function()
{
  app.viewport.action.expandSearch();
});

app.viewport.layout.searchGrid = new Ext.grid.GridPanel(
{
  id: 'viewport-search-grid',
  region: 'center',
  store: new app.base.data.PairStore(),
  stripeRows: true,
  loadMask: true,
  hideHeaders: true,
  bbar: new Ext.Toolbar(
  {
    items: [ app.viewport.layout.searchExpandButton ]
  }),
  width: 300,
  height: 300,
  columns: [{
    id: 'displayText',
    sortable: false,
    dataIndex: 'displayText'
  }],
  autoExpandColumn: 'displayText'
});

app.viewport.layout.searchGrid.on('keypress', function(e)
{
  if(e.getKey() == Ext.EventObject.ENTER)
  {
    app.viewport.action.previewSearch();
  }
});

app.viewport.layout.searchGrid.on('rowdblclick', function(f, i, e)
{
  app.viewport.action.previewSearch();
});

app.viewport.layout.searchWindow = new Ext.Window(
{
  id: 'viewport-search-window',
  layout: 'fit',
  closeAction: 'hide',
  border: false,
  defaultButton: 'viewport-search-input', // TAB and DOWN specialKey event
  items: [ app.viewport.layout.searchGrid ]
});

app.viewport.layout.titlePanel = new Ext.Panel(
{
  id: 'viewport-title-panel',
  region: 'west',
  layout: 'fit',
  width: 160,
  border: false,
  html: "<img src=\"/images/logo.png\"/>"
});

app.viewport.layout.authenticatedPanel = new Ext.Panel(
{
  id: 'viewport-authenticated-panel',
  layout: 'border',
  region: 'center',
  border: false,
  items: [ app.viewport.layout.usernamePanel ]
});

app.viewport.layout.searchPanel = new Ext.Panel(
{
  id: 'viewport-search-panel',
  region: 'east',
  layout: 'anchor',
  width: 240,
  border: false,
  items: [ app.viewport.layout.searchInput ]
});

app.viewport.layout.headerPanel = new Ext.Panel(
{
  id: 'viewport-header-panel',
  layout: 'border',
  region: 'north',
  height: 60,
  items: [ app.viewport.layout.titlePanel,
           app.viewport.layout.authenticatedPanel,
           app.viewport.layout.searchPanel ]
});

app.viewport.layout.menuPanel = new Ext.Panel(
{
  id: 'viewport-menu-panel',
  title: "Gerenciadores",
  layout: 'vbox',
  region: 'west',
  layoutConfig: { align: 'stretch' },
  collapsible: true,
  collapsed: true,
  width: 240,
  items: []
});

app.viewport.layout.statusBar = new Ext.ux.StatusBar(
{
  id: 'viewport-status-bar',
  height: 24,
  busyText: 'Carregando...'
});

app.viewport.layout.contentPanel = new Ext.Panel(
{
  id: 'viewport-content-panel',
  layout: 'card',
  activeItem: 0,
  region: 'center',
  bbar: app.viewport.layout.statusBar,
  items: []
});

app.viewport.layout.workspacePanel = new Ext.Panel(
{
  id: 'viewport-workspace-panel',
  layout: 'border',
  region: 'center',
  border: false,
  items: [ app.viewport.layout.headerPanel,
           app.viewport.layout.contentPanel ]
});

app.viewport.layout.viewport = null;
app.viewport.layout.Viewport = Ext.extend(Ext.Viewport,
{
  constructor: function()
  {
    var config = {
      id: 'viewport',
      layout: 'border',
      items: [ app.viewport.layout.menuPanel,
               app.viewport.layout.workspacePanel ]
    };
      
    app.viewport.layout.Viewport.superclass.constructor.call(this, config);
    app.base.action.debug('viewport created');
  }
});


Ext.namespace('app.viewport.action');

app.viewport.action.registerSection = function(section, wait)
{
  var title = app[section].SECTION_TITLE;
  var sectionButton = new app.base.layout.SectionButton(section, title);
  var contentPanel = Ext.getCmp(section + '-content-panel');
  if(wait==undefined) { wait = 0; }

  (function()
  {
    app.viewport.layout.menuPanel.add(sectionButton);
    app.viewport.layout.contentPanel.add(contentPanel);
  }).defer(wait);

  sectionButton.on('click', function()
  {
    app.viewport.action.setActiveSection(section);
  });

  app.base.action.debug('section "' + section + '" registered on viewport');
}

app.viewport.action.setUsername = function(username)
{
  app.viewport.layout.usernamePanel.update("<span>" + username + "</span>");
  app.base.action.debug('username "' + username + '" set');
}

app.viewport.action.searchRequest = function()
{
  var search = app.viewport.layout.searchInput.getValue();
  var section = app.viewport.action.getActiveSection();

  if(search.length < 3) { return false; }

  var searchGridStore = app.viewport.layout.searchGrid.getStore();
  var search_section = ((app[section].SEARCH_HEAD_SECTION == true) ? app.HEAD_SECTION : section);
  var url = search_section + '/quick';
  var params = { search: search };

  app.viewport.data.searching = true;
  app.viewport.layout.searchGrid.loadMask.show(); 

  app.base.action.debug('search request "' + search + '" started');

  app.base.action.server.store(url, params, searchGridStore, function()
  {
    app.viewport.data.searching = false;
    app.viewport.layout.searchGrid.loadMask.hide(); 

    if(search==app.viewport.layout.searchInput.getValue())
    {
      app.base.action.debug('search request "' + search + '" stoped');
    }
    else
    {
      app.viewport.action.searchRequest();
    }
  });
}

app.viewport.action.showSearchWindow = function()
{
  var searchWindow = app.viewport.layout.searchWindow;
  var viewport = app.viewport.layout.viewport;

  if(searchWindow.isVisible()==false)
  {
    searchWindow.show();
    searchWindow.setPosition(viewport.getWidth() - searchWindow.getWidth() - 17, 47);
  }

  if(app.viewport.data.searching==false)
  {
    app.viewport.action.searchRequest();
  }
}

app.viewport.action.hideSearchWindow = function()
{
  app.viewport.layout.searchWindow.hide();
}

app.viewport.action.expandSearch = function()
{
  var section = app.viewport.action.getActiveSection();
  var search_section = ((app[section].SEARCH_HEAD_SECTION == true) ? app.HEAD_SECTION : section);
  var store = Ext.getCmp(section + '-grid-panel').getStore();
  var search = app.viewport.layout.searchInput.getValue();

  if(search_section != section)
  {
    app.viewport.action.setActiveSection(search_section, true);
    section = search_section;
    store = Ext.getCmp(section + '-grid-panel').getStore();
  }

  if(Ext.isDefined(app.viewport.data.statusParams[section])==false)
  {
    app.viewport.data.statusParams[section] = new Object();
  }

  if(Ext.isEmpty(search))
  {
    delete store.baseParams['search'];
    delete app.viewport.data.statusParams[section]['search'];
    app.base.action.debug('search request contracted');
  }
  else
  {
    store.baseParams['search'] = search;

    // search status always first
    var statusParams = new Object();
        statusParams['search'] = "<span style=\"font-size:small;padding:2px;font-style:italic;\">" + search + "</span>";

    delete app.viewport.data.statusParams[section]['search'];

    app.viewport.data.statusParams[section] = Ext.apply(
      statusParams, app.viewport.data.statusParams[section]
    );

    app.base.action.form.cancel(section);
    app.base.action.debug('search request "' + search + '" expanded');
  }

  app.viewport.action.hideSearchWindow();
  store.load();
  app.viewport.action.status_.update();
}

app.viewport.action.previewSearch = function()
{
  var section = app.viewport.action.getActiveSection();
  var search_section = ((app[section].SEARCH_HEAD_SECTION == true) ? app.HEAD_SECTION : section);
  var searchGrid = app.viewport.layout.searchGrid;
  var id = searchGrid.getSelectionModel().getSelected().id;

  if(search_section != section)
  {
    app.viewport.action.setActiveSection(search_section);
    section = search_section;
  }

  app.viewport.action.hideSearchWindow();

  if(Ext.isEmpty(id)==false)
  {
    app.base.action.preview.load(section, id);
  }
}

app.viewport.action.searchResult = function()
{
  var searchInput = app.viewport.layout.searchInput;

  if(searchInput.getValue().length > 0)
  {
    app.viewport.action.showSearchWindow();
  }
  else
  {
    app.viewport.action.hideSearchWindow();
  }
}

app.viewport.action.setActiveSection = function(section, do_not_load)
{
  var viewportContentPanel = app.viewport.layout.contentPanel;
  var sectionContentPanel = Ext.getCmp(section + '-content-panel');
  var sectionGridPanel = Ext.getCmp(section + '-grid-panel');
  if(do_not_load==undefined) { do_not_load=false; }
  viewportContentPanel.getLayout().setActiveItem(sectionContentPanel);
  app.viewport.action.status_.update();
  app.base.action.grid.show(section);
  if(do_not_load==false) { sectionGridPanel.getStore().load(); }
}

app.viewport.action.getActiveSection = function()
{
  var id = app.viewport.layout.contentPanel.getLayout().activeItem.id;
  return id.replace("-content-panel", '');
}


Ext.namespace('app.viewport.action.status_');

app.viewport.action.status_.set = function(text)
{
  var statusBar = app.viewport.layout.statusBar;

  if(Ext.isEmpty(text))
  {
    statusBar.clearStatus();
  }
  else
  {
    statusBar.setStatus({ text: text });
    app.base.action.debug('status "' + text + '" set');
  }
  /*
  if(text == 'busy')
  {
    statusBar.clearStatus();
    statusBar.showBusy();
  }
  */
}

app.viewport.action.status_.cancel = function()
{
  var section = app.viewport.action.getActiveSection();
  var store = Ext.getCmp(section + '-grid-panel').getStore();
  var statusParams = app.viewport.data.statusParams[section] || {};

  Ext.iterate(statusParams, function(k,j)
  {
    delete app.viewport.data.statusParams[section][k];
    delete store.baseParams[k];
  });

  delete store.baseParams['filter'];
  delete store.baseParams['operator'];

  app.viewport.action.status_.update()
  store.load();

  return false;
}

app.viewport.action.status_.update = function()
{
  var section = app.viewport.action.getActiveSection();
  var statusParams = app.viewport.data.statusParams[section] || {};
  var status_ = new Array();

  Ext.iterate(statusParams, function(k,j)
  {
    // status_.push("<b>" + (k || "").toUpperCase() + ":</b> " + j);
    status_.push(j);
  });

  var statusStr = status_.length > 0 ? 
    ("<a href=\"#\" onclick=\"app.viewport.action.status_.cancel()\"><img src=\"/images/icons/cancel.png\"/></a>&nbsp;" + status_.join(', ')) : 
    "";

  app.viewport.action.status_.set(statusStr);
}
