Ext.namespace('app.eventz');

app.eventz.SECTION_NAME  = 'eventz';
app.eventz.SECTION_TITLE = "Eventos";
app.eventz.SEARCH_HEAD_SECTION = true;
app.eventz.COLUMNS = [
{
  name: 'event[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'event[name]',
  header: "Nome",
  sortable: true
},{
  name: 'event[permalink]',
  header: "Permalink",
  hidden: true,
  sortable: true
},{
  name: 'event[tagline]',
  header: "Descrição curta",
  hidden: true
},{
  name: 'event[tagline]',
  header: "Descrição longa",
  hidden: true,
  sortable: false
},{
  name: 'event_subscribing',
  header: "Inscrições abertas?",
  sortable: true
},{
  name: 'event_image_img',
  header: "Imagem",
  hidden: true
},{
  name: 'members',
  header: "Participantes",
  hidden: true
},{
  name: 'event[created_at]',
  header: "Criado",
  sortable: true
},{
  name: 'event[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.eventz.layout');

app.eventz.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.eventz.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["event"]["name"]);

  if(result["event_image_img"])
  {
    previewContent.addRawHTML(result["event_image_img"] + "<br/>");
  }

  if(result["event_url"])
  {
    previewContent.addRawHTML("<a href=\"" + result["event_url"] + "\" target=\"_blank\">" + result["event_url"] + "</a><br/>&nbsp;<br/>");
  }

  if(result["event"]["tagline"])
  {
    previewContent.addAttribute("Desc. curta", result["event"]["tagline"]);
  }
  if(result["event"]["description"])
  {
    previewContent.addAttribute("Desc. longa", result["event"]["description"]);
  }
  if(result["event_subscribing"])
  {
    previewContent.addAttribute("Inscrevendo?", result["event_subscribing"]);
  }
  if(result["members"])
  {
    previewContent.addAttribute("Participantes", result["members"]);
  }

  if(result["event"]["created_at"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addDateTime("Criado", result["event"]["created_at"]);
  }

  if(result["event"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["event"]["updated_at"]);
  }

  previewPanel.update(previewContent.render());
}


// app.eventz.layout.contentPanel = new app.base.layout.Scaffold(app.eventz.SECTION_NAME);
app.eventz.layout.contentPanel = new app.base.layout.ContentPanel(
  app.eventz.SECTION_NAME,
  [ new app.base.layout.ActionPanel(app.eventz.SECTION_NAME,
      [ new app.base.layout.GridPanel(app.eventz.SECTION_NAME),
        new app.base.layout.FormPanel(app.eventz.SECTION_NAME, null, { fileUpload: true }) ]),
    new app.base.layout.PreviewPanel(app.eventz.SECTION_NAME) ]
);

app.eventz.layout.formPanel = Ext.getCmp(app.eventz.SECTION_NAME + '-form-panel');
app.eventz.layout.formPanel.fileUpload = true;
app.eventz.layout.formPanel.add(
[
  new app.base.form.TextField(app.eventz.SECTION_NAME, 
    'event[name]', "Nome",
    { allowBlank: false }),
  new app.base.form.TextField(app.eventz.SECTION_NAME, 
    'event[permalink]', "Permalink",
    { maskRe: /[a-z0-9\-]/i }),
  new app.base.form.TextField(app.eventz.SECTION_NAME, 
    'event[tagline]', "Descrição curta"),
  new app.base.form.TextArea(app.eventz.SECTION_NAME, 
    'event[description]', "Descrição longa<br/><small>(não implementado)</small>"),
  new app.base.form.TextField(app.eventz.SECTION_NAME, 
    'event_image', "Imagem",
    { inputType: 'file' }),
  new app.base.form.DisplayField(app.eventz.SECTION_NAME, 
    'event_image_img', null,
    { id: app.eventz.SECTION_NAME + '-event-image-viewer' }),
  new app.base.form.Checkbox(app.eventz.SECTION_NAME, 
    'event_image_delete', "Remover imagem?", 'yes'),
  new app.base.form.RadioGroup(app.contact.SECTION_NAME,
    'event_subscribing', "Inscrições abertas", [
      [ "Sim", "Sim" ], 
      [ "Não", "Não" ] ], { columns: 10 })
]);

// unused select button
Ext.getCmp('eventz-select-button').disable();
Ext.getCmp('eventz-grid-panel').getSelectionModel().singleSelect = true;

// every new event has a new container, so it must be updated
app.eventz.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.containerStore.load();
});


app.eventz.layout.nameInput = Ext.getCmp('eventz-event-name-input');
app.eventz.layout.permalinkInput = Ext.getCmp('eventz-event-permalink-input');


Ext.namespace('app.eventz.data');

app.eventz.data.generatingPermalink = false;


Ext.namespace('app.eventz.action');

app.eventz.action.generatePermalink = function()
{
  var input = app.eventz.layout.nameInput.getValue();
  var url = '/eventz/generate_permalink';
  var params = { input: input }

  app.eventz.data.generatingPermalink = true;

  app.base.action.server.request(url, params, function(data)
  {
    app.eventz.layout.permalinkInput.setValue(data.permalink);

    if(input != app.eventz.layout.nameInput.getValue())
    {
      app.eventz.action.generatePermalink();
    }
  });
}

app.eventz.layout.nameInput.on('change', function(f, e)
{
  app.eventz.action.generatePermalink()
});
