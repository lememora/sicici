if(!Array.indexOf) /* Internet Explorer */
{
  Array.prototype.indexOf = function(obj)
  {
    for(var i=0; i<this.length; i++)
    {
      if(this[i]==obj) { return i; }
    }
    return -1;
  }
}


Ext.namespace('app.base');

app.base.DEBUG = false;

app.base.CONNECTION_TYPES = [
  [ 'email',          'Email'     ],
  [ 'phone_home',     'Tel. Res.' ],
  [ 'phone_business', 'Tel. Com.' ],
  [ 'phone_mobile',   'Celular'   ],
  [ 'phone_fax',      'Tel/Fax'   ],
  [ 'fax_only',       'Fax'       ],
  [ 'msn',            'MSN'       ],
  [ 'skype',          'Skype'     ],
  [ 'google_talk',    'GTalk'     ],
  [ 'icq',            'ICQ'       ],
  [ 'website',        'Home-page' ],
  [ 'facebook',       'Facebook'  ],
  [ 'linkedin',       'LinkedIn'  ],
  [ 'twitter',        'Twitter'   ]
];

app.base.CONTAINER_TYPES = [
  [ 'private',           'Privado' ],
  [ 'public',            'Público' ],
  [ 'event',             'Evento' ],
  [ 'temporary_failure', 'Falha temporária' ],
  [ 'permanent_failure', 'Falha permanente' ]
];

app.base.SECTIONS_TOTAL = app.SECTIONS.length;
app.base.SECTION_REGISTER_TIME = 1000;
app.base.STORE_LOAD_TIME = 1000;

app.base.store_load_counter = 0;
app.base.store_load_defer = function()
{
  app.base.store_load_counter++;
  return app.base.store_load_counter * app.base.STORE_LOAD_TIME;
}


Ext.namespace('app.base.data');

app.base.data.PairStore = Ext.extend(Ext.data.ArrayStore,
{
  constructor: function(config)
  {
    this.lastUpdate = new Date();

    config = Ext.apply(
    {
      idIndex: 0,
      fields: [
        { name: 'myId', type: 'string' },
        { name: 'displayText', type: 'string' } ]
    }, config);

    app.base.data.PairStore.superclass.constructor.call(this, config);

    this.on('load', function(t, r, o)
    {
      this.lastUpdate = new Date();
    });
  }
});

app.base.data.countryStore = new app.base.data.PairStore(
{
  url: 'service/countries'
});
(function() { app.base.data.countryStore.load(); }).defer(app.base.store_load_defer());

app.base.data.stateStore = new app.base.data.PairStore();
app.base.data.cityStore = new app.base.data.PairStore();
app.base.data.districtStore = new app.base.data.PairStore();

app.base.data.personalActivityStore = new app.base.data.PairStore(
{
  url: 'service/personal_activities'
});
(function() { app.base.data.personalActivityStore.load(); }).defer(app.base.store_load_defer());

app.base.data.businessActivityStore = new app.base.data.PairStore(
{
  url: 'service/business_activities'
});
(function() { app.base.data.businessActivityStore.load(); }).defer(app.base.store_load_defer());

/*
app.base.data.jobPositionStore = new app.base.data.PairStore(
{
  url: 'service/job_positions'
});
(function() { app.base.data.jobPositionStore.load(); }).defer(app.base.store_load_defer());
*/

app.base.data.containerStore = new app.base.data.PairStore(
{
  url: 'container/containers'
});
(function() { app.base.data.containerStore.load(); }).defer(app.base.store_load_defer());

app.base.data.roleStore = new app.base.data.PairStore(
{
  url: 'user/roles'
});
(function() { app.base.data.roleStore.load(); }).defer(app.base.store_load_defer());

app.base.data.containerTypeStore = new app.base.data.PairStore(
{
  url: 'container/container_types'
});
(function() { app.base.data.containerTypeStore.load(); }).defer(app.base.store_load_defer());

app.base.data.campaignTemplateStore = new app.base.data.PairStore(
{
  url: 'campaign/campaign_templates'
});
(function() { app.base.data.campaignTemplateStore.load(); }).defer(app.base.store_load_defer());

app.base.data.campaignStore = new app.base.data.PairStore(
{
  url: 'campaign/campaigns'
});
(function() { app.base.data.campaignStore.load(); }).defer(app.base.store_load_defer());

app.base.data.printableTemplateStore = new app.base.data.PairStore(
{
  url: 'printable/printable_templates'
});
(function() { app.base.data.printableTemplateStore.load(); }).defer(app.base.store_load_defer());

app.base.data.printableStore = new app.base.data.PairStore(
{
  url: 'printable/printables'
});
(function() { app.base.data.printableStore.load(); }).defer(app.base.store_load_defer());


Ext.namespace('app.base.helper');

app.base.helper.findAttribute = function(d, s)
{
  var a = s.indexOf('[');
  var v = null;

  if(d==undefined) { return null; }

  if(a==-1)
  {
    v = d[s];
  }
  else if(a > 0)
  {
    var b = s.indexOf(']');
    var z = s.length;
    d = d[s.substr(0, a)];
    s = s.substr(a+1, b-a-1) + s.substr(b+1, z-b-1);
    v = app.base.helper.findAttribute(d, s);
  }
  return v;
}

app.base.helper.populate = function(fields, result, raw)
{
  raw = Ext.isDefined(raw) ? raw : false;

  fields.each(function(f)
  {
    if(Ext.isDefined(f.getName))
    {
      var v = app.base.helper.findAttribute(result, f.getName());

      if(Ext.isArray(v))
      {
        Ext.iterate(v, function(j)
        {
          f.setValue(f.getName() + '[' + j + ']', true);
        });
      }
      else
      {
        Ext.isEmpty(v) ? f.setValue('') : (raw ? f.setRawValue(v) : f.setValue(v));
      }
    }
  });
}

app.base.helper.str2id = function(s)
{
  return s.replace(/[^a-z0-9]+/g,'-').replace(/[-]+/g, '-').replace(/^[-]+/,'').replace(/[-]+$/,'').toLowerCase();
}

app.base.helper.dqsb = function(s)
{
  return s.replace(/\[/g,'["').replace(/\]/g,'"]')
}


Ext.namespace('app.base.form');

app.base.form.DisplayField = Ext.extend(Ext.form.DisplayField,
{
  constructor: function(section, name, label, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-display',
      name: name,
      value: ""
    }, config);

    if(label!=undefined && label!=null && label!='')
    {
      config = Ext.apply(
      {
        fieldLabel: label
      }, config);
    }

    app.base.form.DisplayField.superclass.constructor.call(this, config);
  }
});

/* DEPRECATED
app.base.form.ContainerDisplayField = Ext.extend(Ext.form.DisplayField,
{
  constructor: function(section, name, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-display',
      name: name,
      hideLabel: true,
      value: ""
    }, config);

    app.base.form.DisplayField.superclass.constructor.call(this, config);
  },

  setRawValue : function(v)
  {
    var _r = new Array();
    var _a = v.split(/,/)
    var _s = _a.length;
    for(var _j=0; _j<_s; _j++)
    {
      if(_a[_j]!=undefined && _a[_j]!=null && _a[_j]!="")
      {
        _r.push("<small style=\"font-size:8pt;background-color:silver;padding:2px;\">" + _a[_j] + "</small>");
      }
    }
    return this.rendered ? (this.el.dom.innerHTML = (_r.join(' '))) : (this.value = v);
  }
});

app.base.form.AddressDisplayField = Ext.extend(Ext.form.DisplayField,
{
  constructor: function(section, name, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-display',
      name: name,
      hideLabel: true,
      value: ""
    }, config);

    app.base.form.DisplayField.superclass.constructor.call(this, config);
  },

  setRawValue : function(v)
  {
    var addr = new Array();
    var addrs = "";

    if(v['address']!=undefined) { addr.push(v['address']); }
    if(v['district']!=undefined) { addr.push(v['district']); }
    if(v['city']!=undefined) { addr.push(v['city']); }
    if(v['state']!=undefined) { addr.push(v['state']); }
    if(v['code']!=undefined) { addr.push(v['code']); }
    if(v['country_name']!=undefined) { addr.push(v['country_name']); }

    if(addr.length > 0)
    {
      addrs = "<div style=\"margin-top:10px;margin-bottom:10px;\">" + addr.join("<br/>") + "<br/><a href=\"http://maps.google.com/maps?q=" + escape(addr.join(", "))  + "\" target=\"_blank\">mapa</a></div>"
    }
    return this.rendered ? (this.el.dom.innerHTML = (addrs)) : (this.value = v);
  }
});
*/

app.base.form.Hidden = Ext.extend(Ext.form.Hidden,
{
  constructor: function(section, name, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-hidden',
      name: name
    }, config);

    app.base.form.Hidden.superclass.constructor.call(this, config);
  }
});

app.base.form.TextField = Ext.extend(Ext.form.TextField,
{
  constructor: function(section, name, label, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-input',
      fieldLabel: label,
      name: name,
      width: 400,
      labelStyle: 'padding-left:4px;',
      itemCls: 'content-form-item',
      labelSeparator: ''
    }, config);

    app.base.form.TextField.superclass.constructor.call(this, config);
  }
});

app.base.form.TextArea = Ext.extend(Ext.form.TextArea,
{
  constructor: function(section, name, label, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-input',
      fieldLabel: label,
      name: name,
      width: 400,
      labelStyle: 'padding-left:4px;',
      itemCls: 'content-form-item',
      labelSeparator: ''
    }, config);

    app.base.form.TextField.superclass.constructor.call(this, config);
  }
});

app.base.form.ComboBox = Ext.extend(Ext.form.ComboBox,
{
  constructor: function(section, name, label, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-combo',
      fieldLabel: label,
      hiddenId: section + '-' + app.base.helper.str2id(name) + '-hidden',
      hiddenName: name,
      title: null,
      mode: 'local',
      width: 400,
      typeAhead: true,
      triggerAction: 'all',
      name: '_' + name,
      valueField: 'myId',
      displayField: 'displayText',
      labelStyle: 'padding-left:4px;',
      itemCls: 'content-form-item',
      labelSeparator: ''
    }, config);

    if(Ext.isDefined(config.store)==false)
    {
      config = Ext.apply({ store: new app.base.data.PairStore() }, config);
    }

    app.base.form.ComboBox.superclass.constructor.call(this, config);
  }
});

app.base.form.CountryComboBox = Ext.extend(app.base.form.ComboBox,
{
  constructor: function(section, name, label, config)
  {
    app.base.form.CountryComboBox.superclass.constructor.call(
      this, section, name, label, 
      Ext.apply(
      { 
        store: app.base.data.countryStore, 
        valueNotFoundText: '' 
      }, config)
    );
  }
});

app.base.form.DateField = Ext.extend(Ext.form.DateField,
{
  constructor: function(section, name, label, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-date',
      fieldLabel: label,
      name: name,
      format: 'Y-m-d',
      width: 150,
      editable: true,
      labelStyle: 'padding-left:4px;',
      itemCls: 'content-form-item',
      labelSeparator: ''
    }, config);

    app.base.form.DateField.superclass.constructor.call(this, config);
  }
});

app.base.form.Radio = Ext.extend(Ext.form.Radio,
{
  constructor: function(section, name, label, value, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-radio',
      boxLabel: label,
      name: name,
      inputValue: value,
      hideLabel: true,
      itemCls: 'content-form-radio'
    }, config);

    app.base.form.Radio.superclass.constructor.call(this, config);
  }
});

app.base.form.Checkbox = Ext.extend(Ext.form.Checkbox,
{
  constructor: function(section, name, label, value, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-checkbox',
      name: name,
      boxLabel: label,
      inputValue: value
    }, config);

    app.base.form.Checkbox.superclass.constructor.call(this, config);
  }
});

app.base.form.FieldSet = Ext.extend(Ext.form.FieldSet,
{
  constructor: function(section, name, title, items, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-set',
      title: title,
      autoWidth: true,
      labelPad: 10,
      items: items
    }, config);

    app.base.form.FieldSet.superclass.constructor.call(this, config);
  }
});

app.base.form.RadioGroup = Ext.extend(Ext.form.RadioGroup,
{
  constructor: function(section, name, label, data, config)
  {
    data = data || [];

    var items = new Array();

    Ext.iterate(data, function(j)
    {
      items.push({ name: name, boxLabel: j[1], inputValue:j[0], itemCls: 'content-form-radio' });
      
    });

    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-group',
      fieldLabel: label,
      hideLabel: Ext.isEmpty(label) ? true : false,
      name: name,
      labelStyle: 'padding-left:4px;',
      itemCls: 'content-form-item',
      labelSeparator: '',
      items: items
    }, config);

    app.base.form.RadioGroup.superclass.constructor.call(this, config);
  }
});

app.base.form.CheckboxGroup = Ext.extend(Ext.form.CheckboxGroup,
{
  constructor: function(section, name, label, data, config)
  {
    data = data || [];

    var items = new Array();

    Ext.iterate(data, function(j)
    {
      items.push({ name: name + '[' + j[0] + ']', boxLabel: j[1], inputValue:j[0] });
    });

    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-group',
      fieldLabel: label,
      hideLabel: Ext.isEmpty(label) ? true : false,
      labelStyle: 'padding-left:4px;',
      name: name,
      columns: 1,
      autoScroll: true,
      labelSeparator: '',
      items: items
    }, config);

    app.base.form.CheckboxGroup.superclass.constructor.call(this, config);
  }
});

app.base.form.StoreCheckboxGroup = Ext.extend(app.base.form.CheckboxGroup,
{
  constructor: function(section, name, store, config)
  {
    var data = new Array();

    store.each(function(j)
    {
      data.push([ j.data.myId, j.data.displayText ]);
    });

    app.base.form.StoreCheckboxGroup.superclass.constructor.call(this,
      section, name, null, data, config); 

    this.reset();
  }
});

app.base.form.LocalizationFieldSet = Ext.extend(Ext.form.FieldSet,
{
  constructor: function(section, name, title, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + app.base.helper.str2id(name) + '-set',
      title: title,
      autoWidth: true,
      labelPad: 10,
      style: title==null ? 'padding-left:0px;padding-bottom:0px;' : '',
      border: title==null ? false : true,
      items: [
        new app.base.form.CountryComboBox(section,
          name + "[country]", "País"),
        new app.base.form.TextField(section,
          name + "[code]", "Código Postal (CEP, ZIP, etc.)", 
          { maskRe: /[a-z0-9\s\-]/i, width: 200 }),
        new app.base.form.TextField(section,
          name + '[state]', "Estado", 
          { width: 300 }),
        new app.base.form.TextField(section,
          name + '[city]', "Cidade", 
          { width: 300 }),
        new app.base.form.TextField(section,
          name + '[district]', "Bairro/Distrito", 
          { width: 300 }),
        new app.base.form.TextField(section,
          name + '[address]', "Endereço")
      ]
    }, config);

    app.base.form.LocalizationFieldSet.superclass.constructor.call(this, config);
  }
});


Ext.namespace('app.base.layout');

app.base.layout.Button = Ext.extend(Ext.Button,
{
  constructor: function(section, name, text, icon, action, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + name + '-button',
      text: text,
      icon: 'images/icons/' + icon + '.png'
    }, config);

    app.base.layout.Button.superclass.constructor.call(this, config);

    if(Ext.isDefined(action)) { this.on('click', action); }
  }
});

app.base.layout.ToggleButton = Ext.extend(Ext.Button,
{
  constructor: function(section, name, text, icon, action, config)
  {
    config = Ext.apply(
    {
      id: section + '-' + name + '-button',
      text: text,
      icon: 'images/icons/' + icon + '.png',
      enableToggle: true
    }, config);

    app.base.layout.ToggleButton.superclass.constructor.call(this, config);

    if(Ext.isDefined(action)) { this.on('toggle', action); }
  }
});

app.base.layout.SectionButton = Ext.extend(Ext.Button,
{
  constructor: function(section, title, config)
  {
    config = Ext.apply(
    {
      id: section + '-section-button',
      text: title,
      cls: 'section-button'
    }, config);

    app.base.layout.SectionButton.superclass.constructor.call(this, config);
  }
});

app.base.layout.ContentPanel = Ext.extend(Ext.Panel,
{
  constructor: function(section, items, config)
  {
    config = Ext.apply(
    {
      id: section + '-content-panel',
      title: "Gerenciador de " + app[section].SECTION_TITLE,
      layout: 'border',
      border: false,
      items: [].concat(items || [])
    }, config);

    app.base.layout.ContentPanel.superclass.constructor.call(this, config);
  }
});

app.base.layout.ActionPanel = Ext.extend(Ext.Panel,
{
  constructor: function(section, items, config)
  {
    config = Ext.apply(
    {
      id: section + '-action-panel',
      layout: 'card',
      activeItem: 0,
      region: 'center',
      items: [].concat(items || [])
    }, config);

    app.base.layout.ActionPanel.superclass.constructor.call(this, config);
  }
});

app.base.layout.rendererForBoolean = function(value, metaData, record, rowIndex, colIndex, store)
{
  if(value==true)  { value = "Sim"; }
  if(value==false) { value = "Não"; }
  return value;
}

app.base.layout.rendererForEmail = function(value, metaData, record, rowIndex, colIndex, store)
{
  if(value!=undefined && value!=null)
  {
    value = "<a href=\"mailto:" + value + "\">" + value + "</a>";
  }
  return value;
}

app.base.layout.GridPanel = Ext.extend(Ext.grid.GridPanel,
{
  constructor: function(section, tbuttons, bbuttons, config)
  {
    var url = section + '/list';
    var columns = app[section].COLUMNS;
    var default_sort = app[section].DEFAULT_SORT;

    var toolbar = new Ext.Toolbar(
    {
      items: [
        new app.base.layout.Button(
          section, 'add', "Adicionar", 'add', function() {
          app.base.action.form.add(section);
        }, { disabled: (app.SECTIONS_WRITABLE.indexOf(section)<0) }),
        new app.base.layout.Button(
          section, 'edit', "Editar", 'database_edit', function() {
          app.base.action.form.edit(section);
        }, { disabled: true }),
        new app.base.layout.Button(
          section, 'delete', "Remover", 'delete', function() {
          app.base.action.grid.deleteConfirm(section);
        }, { disabled: true })
      ].concat(tbuttons || [])
    });

    var totalColumns = columns.length;
    var storeFields =  new Array();
    var gridColumns = new Array();

    for(var j=0; j<totalColumns; j++)
    {
      storeFields.push(
      { 
        name: columns[j].name,
        mapping: Ext.isDefined(columns[j].mapping) ?
                   columns[j].mapping :
                   app.base.helper.dqsb(columns[j].name)
      });
      gridColumns.push(
      {
        id: columns[j].name,
        header: columns[j].header,
        hidden: Ext.isDefined(columns[j].hidden) ? columns[j].hidden : false,
        sortable: Ext.isDefined(columns[j].sortable) ? columns[j].sortable : false,
        width: Ext.isDefined(columns[j].width) ? columns[j].width : 200,
        renderer: Ext.isDefined(columns[j].renderer) ? columns[j].renderer : undefined,
        dataIndex: columns[j].name
      });
    }

    var store = new Ext.data.Store(
    {
      remoteSort: true,
      baseParams: { },
      proxy: new Ext.data.HttpProxy(
      {
        url: url,
        method: 'GET'
      }),
      reader: new Ext.data.JsonReader(
      {
        idProperty: Ext.isDefined(columns[0].mapping) ?
                      columns[0].mapping :
                      app.base.helper.dqsb(columns[0].name),
        root: 'results',
        totalProperty: 'total',
        fields: storeFields
      })
    });

    if(default_sort) { 
      var ds = default_sort.split(/\s/)
      store.setDefaultSort(ds[0], ds[1]);
    } else {
      store.setDefaultSort(columns[1].name, 'ASC');
    }

    var selectedTextField = new app.base.form.TextField(
      section, 'selected', null, 
      { value: "0", width: 50, readOnly: true, style: "text-align:right;" }
    );

    var totalDisplayField = new app.base.form.DisplayField(
      section, 'total', null,
      { value: "0", style: 'font-size:14px;' }
    );

    var selectButton = new app.base.layout.ToggleButton(
      section, 'select', "Selecionar", 'asterisk_yellow',
      function(b, p)
      {
        app.base.action.grid.toggle(section, p);
        b.blur();
      }
    );

    var paging = new Ext.PagingToolbar(
    {
      pageSize: 25,
      store: store,
      items: [ '->', 
        'Selecionados', selectedTextField,
        'de ', totalDisplayField,
        '&nbsp;', selectButton ].concat(bbuttons || [])
    });

    config = Ext.apply(
    {
      id: section + '-grid-panel',
      region: 'center',
      store: store,
      stripeRows: true,
      loadMask: true,
      tbar: toolbar,
      bbar: paging,
      border: false,
      columns: gridColumns,
      autoExpandColumn: columns[1].name
    }, config);

    app.base.layout.GridPanel.superclass.constructor.call(this, config);
    app.base.action.debug('"' + section + '" grid panel created');

    var selectionModel = this.getSelectionModel();

    this.on('keypress', function(e)
    {
      if(e.getKey() == Ext.EventObject.ENTER)
      {
        app.base.action.grid.preview(section);
      }
    });

    this.on('rowdblclick', function(f, i, e)
    {
      app.base.action.grid.preview(section);
    });

    store.on('load', function()
    {
      if(selectButton.pressed)
      {
        selectionModel.selectAll()
      }

      totalDisplayField.setValue(this.getTotalCount());
    });

    selectionModel.on('rowdeselect', function()
    {
      if(selectButton.pressed && selectionModel.getCount() != store.getCount())
      {
        selectButton.toggle();
      }
    });

    selectionModel._selection_working = false;

    selectionModel.on('selectionchange', function()
    {
      if(selectButton.pressed==false && selectionModel._selection_working==false)
      {
        selectionModel._selection_working = true;
        (function()
        { 
          var selectionsTotal = app.base.action.grid.selections(section).length;
          selectedTextField.setValue(selectionsTotal);
          selectionModel._selection_working = false; 

          if(selectionsTotal==1 && (app.SECTIONS_WRITABLE.indexOf(section)>=0))
          {
            Ext.getCmp(section + '-edit-button').enable();
          }
          else
          {
            Ext.getCmp(section + '-edit-button').disable();
          }

          if(selectionsTotal > 0 && (app.SECTIONS_WRITABLE.indexOf(section)>=0))
          {
            Ext.getCmp(section + '-delete-button').enable();
          }
          else
          {
            Ext.getCmp(section + '-delete-button').disable();
          }
        }).defer(50);
      }
    });
  }
});

app.base.layout.FormPanel = Ext.extend(Ext.FormPanel,
{
  constructor: function(section, items, config)
  {
    var columns = app[section].COLUMNS;

    config = Ext.apply(
    {
      id: section + '-form-panel',
      bbar: new Ext.Toolbar({ items: [
        new app.base.layout.Button(section, 'form-cancel', "Cancelar", 'cancel',
          function() { app.base.action.form.cancel(section) }),
        new app.base.layout.Button(section, 'form-save', "Salvar", 'disk',
          function() { app.base.action.form.submit(section) })
      ]}),
      border: false,
      autoScroll: true,
      cls: 'content-form-panel',
      labelWidth: 200,
      labelPad: 11,
      items: [ new app.base.form.Hidden(section, columns[0].name) ].concat(items || [])
    }, config);

    app.base.layout.FormPanel.superclass.constructor.call(this, config);
    this.addEvents('populate');
    app.base.action.debug('"' + section + '" form panel created');

    this.on('populate', function()
    {
      app.base.action.debug('"' + section + '" form panel populated');
    });
  }
});

app.base.layout.PreviewPanel = Ext.extend(Ext.Panel,
{
  constructor: function(section, buttons, config, items)
  {
    var toolbar = new Ext.Toolbar(
    {
      items: [
        new app.base.layout.Button(
          section, 'preview-edit', "Editar", 'database_edit', function() {
          app.base.action.preview.edit(section);
        }, { disabled: true })
      ].concat(buttons || [])
    });

    config = Ext.apply(
    {
      id: section + '-preview-panel',
      cls: 'preview-panel',
      layout: 'form',
      region: 'east',
      bodyStyle: 'padding:16px;',
      width: 280,
      split: true,
      autoScroll: true,
      bbar: toolbar,
      disabled: true
    }, config);

    app.base.layout.PreviewPanel.superclass.constructor.call(this, config);
  }
});

app.base.layout.PreviewContent = function()
{
  this.body = new String();

  this.addRawHTML = function(html)
  {
    this.body += html;
  }

  this.addTitle = function(title)
  {
    this.body += "<h1 style=\"font-size:large;line-height:28px;\">" + title + "</h1>";
  }

  this.addSubtitle = function(subtitle)
  {
    this.body += "<h2 style=\"font-size:medium;font-weight:normal;line-height:24px;\">" + subtitle + "</h2>";
  }

  this.addAttribute = function(label, value)
  {
    this.body += "<table><tr><th valign=\"top\" style=\"vertical-align:top;width:80px;padding-right:10px;color:gray;font-size:small;\">" + label + "</th><td style=\"font-size:small;\">" + value + "</td></tr></table>";
  }

  this.addTags = function(containers)
  {
    if(containers==undefined ||
       containers==null ||
       containers=='') { containers = []; }

    var total = containers.length;

    if(total > 0) { this.body += "&nbsp;<br/>"; }

    for(var j=0; j<total; j++)
    {
      this.body += "<span style=\"font-size:x-small;padding:2px;background-color:silver;white-space:nowrap;\">" + containers[j] + "</span> ";
    }

    if(total > 0) { this.body += "<br/>&nbsp;<br/>"; }
  }

  this.addEmail = function(email)
  {
    if(email!=undefined &&
       email!=null &&
       email!='')
    {
      this.body += "<a href=\"mailto:" + email + "\">" + email + "</a><br/>";
    }
  }

  this.addDate = function(label, value)
  {
    if(value!=undefined && value!=null)
    {
      this.addAttribute(label, Date.parseDate(value, 'Y-m-d').format('d/m/Y'));
    }
  }

  this.addDateTime = function(label, value)
  {
    if(value!=undefined && value!=null)
    {
      this.addAttribute(label, Date.parseDate(value, 'Y-m-d H\\hi').format('d/m/Y H\\hi'));
    }
  }

  this.addGender = function(label, value)
  {
    value_str = "";
    if(value=="male" || value=="m") { value_str = "Masculino"; }
    if(value=="female" || value=="f") { value_str = "Feminino"; }
    this.addAttribute(label, value_str);
  }

  this.addAddress = function(label, value, mark)
  {
    addr = new Array(); 
    addr_str = "";
    if(mark==undefined) { mark==false; }

    if(value==undefined) { value = {}; }

    if(value["address"])      { addr.push(value["address"]); }
    if(value["district"])     { addr.push(value["district"]); }
    if(value["city"])         { addr.push(value["city"]); }
    if(value["state"])        { addr.push(value["state"]); }
    if(value["code"])         { addr.push(value["code"]); }
    if(value["country_name"]) { addr.push(value["country_name"]); }

    if(addr.length > 0)
    {
      if(mark==true) { addr_str += "<b>" + addr.join("<br/>") + "</b>"; }
      else           { addr_str += addr.join("<br/>"); }
      addr_str += "<br/>(<a href=\"http://maps.google.com/maps?q=" + escape(addr.join(" - "))  + "\" target=\"_blank\" style=\"font-size:small;\">mapa</a>)"
      this.body += "&nbsp;<br/>";
      this.addAttribute(label, addr_str);
    }
  }

  this.addConnections = function(connections, prefered)
  {
    var types = app.base.CONNECTION_TYPES;
    var total = types.length;
    var index = null;
    var label = null;
    var attrs = new Array();
    if(prefered==undefined) { prefered = null; }

    for(var j=0; j<total; j++)
    {
      index = types[j][0];
      label = types[j][1];
      if(connections[index])
      {
        if(prefered && prefered.indexOf(connections[index])>=0)
        {
          attrs.push([label, ("<b>" + connections[index] + "</b>")]);
        }
        else
        {
          attrs.push([label, (connections[index])]);
        }
      }
    }

    total = attrs.length;
    if(total>0) { this.body += "&nbsp;<br/>"; }
    for(j=0;j<total;j++) { this.addAttribute(attrs[j][0], attrs[j][1]); }
  }

  this.render = function()
  {
    return "<div class=\"preview-content\">" + this.body + "</div>";
  }
}

app.base.layout.Scaffold = Ext.extend(app.base.layout.ContentPanel,
{
  constructor: function(section)
  {
    app.base.layout.Scaffold.superclass.constructor.call(
      this, section, 
      [ new app.base.layout.ActionPanel(section,
          [ new app.base.layout.GridPanel(section),
            new app.base.layout.FormPanel(section) ]),
        new app.base.layout.PreviewPanel(section) ]
    );
  }
});

app.base.layout.FilterWindow = Ext.extend(Ext.Window,
{
  constructor: function(section, name, title, store, config)
  {
    this.lastUpdate = new Date();

    var filter = app.base.helper.str2id(name) + '-filter';

    var applyButton = new app.base.layout.Button(section,
      filter + '-set', "Aplicar", 'arrow_in', function() {
    }, { disabled: (app.SECTIONS_WRITABLE.indexOf(section)<0) });

    var commandComboBox = new app.base.form.ComboBox(section,
      filter + '-command', "",
      { store: new app.base.data.PairStore({ data: [
        [ 'insert',  "Adicionar"],
        [ 'delete',  "Remover"],
        [ 'replace', "Sobrescrever" ] ] }),  
        width: 120, forceSelection: true, autoSelect: true, editable: false,
        disabled: (app.SECTIONS_WRITABLE.indexOf(section)<0)
      }
    );

    var expandButton = new app.base.layout.Button(section,
      filter + '-expand', "Buscar", 'arrow_left', function() {
    });

    var filterComboBox = new app.base.form.ComboBox(section,
      filter + '-operator', "",
      { store: new app.base.data.PairStore({ data: [
        [ 'OR',  "Qualquer um"],
        [ 'AND', "Todos" ] ] }),  
        width: 120, forceSelection: true, autoSelect: true, editable: false
      }
    );

    filterComboBox.setValue('OR');

    config = Ext.apply(
    {
      id: section + '-' + filter + '-window',
      title: title,
      layout: 'fit',
      closeAction: 'hide',
      width: 480,
      height: 320,
      border: false,
      loadMask: true,
      tbar: [ applyButton, '->', commandComboBox ],
      bbar: [ expandButton, '->', filterComboBox ]
    }, config);

    app.base.layout.FilterWindow.superclass.constructor.call(this, config);

    applyButton.on('click', function()
    {
      if(commandComboBox.getValue()=='replace')
      {
        Ext.Msg.show(
        {
          msg: "Deseja mesmo sobrescrever?",
          buttons: Ext.Msg.YESNO,
          fn: function(b)
          {
            if(b=='yes')
            {
              app.base.action.filter.apply(section, filter);
            }
          },
          icon: Ext.MessageBox.QUESTION
        });
      }
      else
      {
        app.base.action.filter.apply(section, filter);
      }
    });

    expandButton.on('click', function()
    {
      app.base.action.filter.expand(section, filter);
    });

    this.on('beforeshow', function()
    {
      var viewport = Ext.getCmp('viewport');
      this.setPosition(viewport.getWidth() - this.getWidth() - 80, 128);

      commandComboBox.setValue('insert');

      var checkboxGroup = null;

      if(Math.abs(this.lastUpdate.getElapsed(store.lastUpdate)) > 0)
      {
        checkboxGroup = new app.base.form.StoreCheckboxGroup(
          section, name, store, { id: section + '-' + filter + '-group',
            style: 'padding:10px;' });

        /// var expanded = app.base.action.filter.expanded(section, filter); ???

        // this is very inconvenient...
        // if there is a lot of checkboxes to load, application will freeze
        app.boot.layout.loadMask = new Ext.LoadMask(this.body,
        {
          //msg: "Loading...",
          removeMask: true
        });
        app.boot.layout.loadMask.show();    
        (function()
        {
          app.boot.layout.loadMask.hide();
        }).defer((30 * store.getCount()) + 1000); // approximated

        var _this__ = this;

        (function()
        {
          _this__.removeAll();
          _this__.add(checkboxGroup);
          _this__.doLayout();
          _this__.lastUpdate = store.lastUpdate;
        }).defer(1000);
      }

      if(checkboxGroup==null)
      {
        checkboxGroup = Ext.getCmp(section + '-' + filter + '-group');
      }

      if(checkboxGroup != undefined &&
         checkboxGroup != null)
      {
        checkboxGroup.reset();
      }
    });
  }
});


Ext.namespace('app.base.action');

app.base.action.debug = function(text)
{
  if(app.base.DEBUG == false) { return false; }

  if(Ext.isDefined(console) && Ext.isDefined(console.log))
  {
    console.log(text);
  }
}

Ext.namespace('app.base.action.server');

app.base.action.server.request = function(url, params, callback, method)
{
  if(typeof params == "number") { params = { id: parseInt(params) }; }

  Ext.Ajax.request({
    url: url,
    params: params,
    method: method ? method : 'GET',
    timeout: 300000,
    success: function(response)
    {
      callback(Ext.decode(response.responseText));
    }
  });
}

app.base.action.server.get = function(url, params, callback)
{
  app.base.action.server.request(url, params, callback, 'GET');
}

app.base.action.server.post = function(url, params, callback)
{
  app.base.action.server.request(url, params, callback, 'POST');
}

app.base.action.server.load = function(section, id, callback)
{
  app.base.action.server.get(section + '/load', id, 
    function(data) { callback(data.result); });
}

app.base.action.server.delete_ = function(section, ids, callback)
{
  app.base.action.server.post(section + '/delete', ids, 
    function(data) { callback(data.result); });
}

app.base.action.server.delete_all_ = function(section, params, callback)
{
  app.base.action.server.post(section + '/delete_all', params, 
    function(data) { callback(data.result); });
}

app.base.action.server.store = function(url, params, store, callback)
{
  app.base.action.server.get(url, params, function(data)
  {
    store.loadData(data);
    if(callback!=undefined) { callback(); }
  });
}


Ext.namespace('app.base.action.grid');

app.base.action.grid.show = function(section)
{
  var actionPanel = Ext.getCmp(section + '-action-panel');
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  actionPanel.getLayout().setActiveItem(gridPanel);
}

app.base.action.grid.load = function(section)
{
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  gridPanel.getStore().reload();
}

app.base.action.grid.preview = function(section)
{
  var id = app.base.action.grid.selected(section);
  if(id==0) { return false; }
  app.base.action.preview.load(section, id);
}

app.base.action.grid.selected = function(section, alert_)
{
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  var selected = gridPanel.getSelectionModel().getSelected();

  if(alert_==undefined) { alert_ = false; } else { alert_ = true; }

  if(alert_==true && selected==undefined)
  {
    Ext.Msg.alert("Nenhum item selecionado");
    selected = { id: 0 };
  }

  return selected;
}

app.base.action.grid.selections = function(section)
{   
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  var selections = gridPanel.getSelectionModel().getSelections() || [];
  return selections;
}

app.base.action.grid.toggle = function(section, selected)
{
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  var totalCount = gridPanel.getStore().getTotalCount();
  var selectedInput = Ext.getCmp(section + '-selected-input');

  if(selected)
  {
    gridPanel.getSelectionModel().selectAll();
    selectedInput.setValue(totalCount);
    Ext.getCmp(section + '-edit-button').disable();
    Ext.getCmp(section + '-delete-button').enable();
  }
  else
  {
    gridPanel.getSelectionModel().clearSelections();
    selectedInput.setValue(0);
  }
}

app.base.action.grid.delete_ = function(section)
{
  var gridPanel = Ext.getCmp(section + '-grid-panel');
  var totalDisplay = Ext.getCmp(section + '-total-display');
  Ext.each(app.base.action.grid.selections(section), function(j)
  {
    gridPanel.getStore().remove(j);
    totalDisplay.setValue(gridPanel.getStore().getTotalCount() - 1);
  });
}

app.base.action.grid.deleteConfirm = function(section)
{
  Ext.Msg.show(
  {
    msg: "Deseja remover os itens selecionados?",
    buttons: Ext.Msg.YESNO,
    fn: function(b)
    {
      if(b=='yes')
      {
        if(Ext.getCmp(section + '-select-button').pressed==true)
        {
          var gridPanelStore = Ext.getCmp(section + '-grid-panel').getStore();

          app.base.action.server.delete_all_(section, gridPanelStore.baseParams, function(data)
          {
            app.base.action.grid.delete_(section);
            gridPanelStore.reload();
          });
        }
        else
        {
          var ids = new Array();
          Ext.each(app.base.action.grid.selections(section), function(j) { ids.push(j.id); });

          app.base.action.server.delete_(section, { ids: ids.join(',') }, function(data)
          {
            app.base.action.grid.delete_(section);
          });
        }
      }
    },
    icon: Ext.MessageBox.QUESTION
  }); 
}


Ext.namespace('app.base.action.filter');

app.base.action.filter.selected = function(section, filter)
{
  var filterGroup = Ext.getCmp(section + '-' + filter + '-group');
  var selected = new Array();
  
  filterGroup.items.each(function(f)
  {
    if(f.getValue()==true)
    {
      selected.push([ f.getRawValue(), f.boxLabel ]);
    }
  });

  return selected;
}

app.base.action.filter.expand = function(section, filter)
{
  var gridPanelStore = Ext.getCmp(section + '-grid-panel').getStore();
  var selected = app.base.action.filter.selected(section, filter);
  var operator = Ext.getCmp(section + '-' + filter + '-operator-combo').getValue();
  var filterName = filter.replace('-filter', '');

  var selectedLabels = Array();
  var selectedValues = Array();

  Ext.iterate(selected, function(j)
  {
    selectedValues.push(j[0]);
    // selectedLabels.push(j[1]);
    selectedLabels.push("<span style=\"font-size:small;padding:2px;background-color:silver;white-space:nowrap;\">" + j[1] + "</span>");
  });

  if(Ext.isDefined(app.viewport.data.statusParams[section])==false)
  {
    app.viewport.data.statusParams[section] = new Object();
  }

  if(selectedValues.length > 0)
  { 
    gridPanelStore.baseParams['filter'] = filterName + ':' + selectedValues.join(',');
    gridPanelStore.baseParams['operator'] = operator;
    var filterStatus = selectedLabels.join((operator=='OR') ? " ou " : " + ");
    app.viewport.data.statusParams[section][filterName] = filterStatus;
  }
  else
  {
    delete gridPanelStore.baseParams['filter'];
    delete gridPanelStore.baseParams['operator'];
    delete app.viewport.data.statusParams[section][filterName] ;
  }

  gridPanelStore.load();
  app.viewport.action.status_.update();
}

app.base.action.filter.expanded = function(section, filter)
{
  var gridPanelStore = Ext.getCmp(section + '-grid-panel').getStore();
  var filterValues = new Array();
  var filterName = filter.replace('-filter', '');

  if((gridPanelStore.baseParams['filter'] || "").indexOf(filterName + ':')>=0)
  {
    var filterSplit = gridPanelStore.baseParams['filter'].split(':');
    filterValues = filterSplit.pop().split(',') || [];
  }

  return filterValues;
}

app.base.action.filter.apply = function(section, filter)
{
  var gridPanelStore = Ext.getCmp(section + '-grid-panel').getStore();
  var gridSelectAll = Ext.getCmp(section + '-select-button').pressed;
  var gridSelections = app.base.action.grid.selections(section);
  var gridIds = new Array();
  var expandedFilters = app.base.action.filter.expanded(section, filter);
  var selectedFilters = app.base.action.filter.selected(section, filter);
  var filterName = filter.replace('-filter', '');
  var command = Ext.getCmp(section + '-' + filter + '-command-combo').getValue();

  if(gridSelectAll)
  {
    gridIds = [ '*' ];
  }
  else
  {
    Ext.each(gridSelections, function(j) { gridIds.push(j.id); });
  }

  app.base.action.server.post(section + '/' + filterName,
    Ext.apply(
    {
      expanded: expandedFilters.join(","),
      selected: selectedFilters.join(","),
      ids: gridIds.join(","),
      command: command
    }, gridPanelStore.baseParams),
    function(data)
    {
      app.base.action.grid.load(section);
    }
  );
}


Ext.namespace('app.base.action.form');

app.base.action.form.populate = function(section, result)
{
  var formPanel = Ext.getCmp(section + '-form-panel');
  app.base.helper.populate(formPanel.getForm().items, result);
  formPanel.fireEvent('populate');
}

app.base.action.form.load = function(section, id)
{
  app.base.action.server.load(section, id, function(result)
  {
    app.base.action.form.populate(section, result);
  })
}

app.base.action.form.show = function(section, id)
{
  var actionPanel = Ext.getCmp(section + '-action-panel');
  var formPanel = Ext.getCmp(section + '-form-panel');

  actionPanel.getLayout().setActiveItem(formPanel);
  formPanel.getForm().getEl().scrollTo('top', 0);

  if(Ext.isEmpty(id)==false)
  {
    app.base.action.form.load(section, id);
  }
}

app.base.action.form.submit = function(section)
{
  var formPanel = Ext.getCmp(section + '-form-panel');

  formPanel.getForm().submit(
  {
    url: section + '/save',
    method: 'POST',
    clientValidation: true,
    waitTitle: "Aguarde",
    waitMsg: "Enviando formulário...",
    success: function(form, action)
    {
      var data = null;
      var entry = null;

      if(Ext.isDefined(action.response))
      {
        data = Ext.util.JSON.decode(action.response.responseText);
      }

      if(Ext.isEmpty(data)==false)
      {
        entry = data.id;
      }

      formPanel.getForm().reset();
      app.base.action.grid.show(section);
      app.base.action.preview.load(section, entry);
      app.base.action.grid.load(section);
    },
    failure: function(form, action)
    {
      var message = "Erro desconhecido";
      var data = null;

      if(action.response)
      {
        data = Ext.util.JSON.decode(action.response.responseText);
      }

      /* client side validation */
      switch(action.failureType)
      {
        case Ext.form.Action.CLIENT_INVALID:
          message = "Verifique o preenchimento dos campos";
        break;
        case Ext.form.Action.CONNECT_FAILURE:
          message = "Erro na conexão, Tente novamente";
        break;
        case Ext.form.Action.SERVER_INVALID:
          message = "Comunique ao fornecedor a seguinte mensagem: " + o.result.msg;
        break;
      }

      /* server side validation */
      if(Ext.isEmpty(data)==false)
      {
        message = data.errors[0][1];

        var field = formPanel.getForm().findField(data.errors[0][0]);

        if(field!=undefined ||
           field!=null)
        {
          field.markInvalid(data.errors[0][1]);
          field.focus();
        }
      }

      Ext.Msg.alert("Aviso", message);
    }
  });
}

app.base.action.form.cancel = function(section)
{
  var formPanel = Ext.getCmp(section + '-form-panel');

  if(formPanel.getForm().isDirty()==false)
  {
    formPanel.getForm().reset();
    app.base.action.grid.show(section);
    return true;
  }

  Ext.Msg.show(
  {
    msg: "Deseja abandonar as alterações?",
    buttons: Ext.Msg.YESNO,
    fn: function(b)
    {
      if(b=='yes')
      {
        formPanel.getForm().reset();
        app.base.action.grid.show(section);
      }
    }
  });
}

app.base.action.form.found = function(section, result, input)
{
  var formPanel = Ext.getCmp(section + '-form-panel');

  Ext.Msg.confirm('Registro Encontrado',
    'Já existe um registro com estas informações. Deseja carregá-lo?',
    function(button)
    {
      if(button=='yes')
      {
        app.base.action.form.populate(section, result);
      }
      else
      {
        input.focus();
        input.selectText();
      }
    }
  );
}

app.base.action.form.add = function(section)
{
  app.base.action.form.show(section);
}

app.base.action.form.edit = function(section)
{
  var id = app.base.action.grid.selected(section, true).id
  if(id==0) { return false; }
  app.base.action.form.show(section, id);
}


Ext.namespace('app.base.action.preview');

app.base.action.preview.populate = function(section, result)
{
  var columns = app[section].COLUMNS;
  var previewFormPanel = Ext.getCmp(section + '-preview-form-panel');
  var titlePanel = Ext.getCmp(section + '-preview-title-panel');
  app.base.helper.populate(previewFormPanel.getForm().items, result, true);
  var title = app.base.helper.findAttribute(result, columns[1].name);
  titlePanel.update("<span>" + title + "</span>");
  previewFormPanel.fireEvent('populate');
}

app.base.action.preview.edit = function(section)
{
  var id = app[section].currentId || 0;
  if(id==0) { return false; }
  app.base.action.form.show(section, id);
}

app.base.action.preview.load = function(section, id)
{
  var previewPanel = Ext.getCmp(section + '-preview-panel');
  var previewEditButton = Ext.getCmp(section + '-preview-edit-button');
  var editButton = Ext.getCmp(section + '-edit-button');
  
  if(app[section].layout.previewContent==undefined) // must implement
  {
    return false;
  }

  previewPanel.enable();

  if(app.SECTIONS_WRITABLE.indexOf(section)>=0)
  {
    if(editButton.disabled == false)
    {
      previewEditButton.enable();
    }
    app[section].currentId = id;
  }

  app.base.action.server.load(section, id, function(result)
  {
    app[section].layout.previewContent(result);
  })
}
