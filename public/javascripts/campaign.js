Ext.namespace('app.campaign');

app.campaign.SECTION_NAME  = 'campaign';
app.campaign.SECTION_TITLE = "Campanhas";
app.campaign.SEARCH_HEAD_SECTION = true;
app.campaign.COLUMNS = [
{
  name: 'campaign[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'campaign[name]',
  header: "Nome",
  sortable: true
},{
  name: 'campaign_template',
  header: "Template",
  sortable: true
},{
  name: 'campaign_periodicity',
  header: "Periodicidade",
  hidden: true
},{
  name: 'campaign_enabled',
  header: "Ativo?",
  hidden: true
},{
  name: 'campaign[created_at]',
  header: "Criado",
  sortable: true
},{
  name: 'campaign[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.campaign.layout');

app.campaign.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.campaign.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["campaign"]["name"]);
  previewContent.addSubtitle(result["campaign_template"]);

  if(result["container_names"])
  {
    previewContent.addTags(result["container_names"].split(','));
  }

  if(result["campaign_periodicity"])
  {
    previewContent.addAttribute("Periodicidade", result["campaign_periodicity"]);
  }

  if(result["campaign"]["content_title"] ||
     result["campaign"]["content_subtitle"] ||
     result["campaign"]["content_body"] ||
     result["campaign_image_img"])
  {
    previewContent.addRawHTML("&nbsp;<br/><u>Conteúdo</u>&nbsp;<br/>");
  }
  if(result["campaign"]["content_title"])
  {
    previewContent.addAttribute("Título", result["campaign"]["content_title"]);
  }
  if(result["campaign"]["content_subtitle"])
  {
    previewContent.addAttribute("Subtítulo", result["campaign"]["content_subtitle"]);
  }
  if(result["campaign"]["content_body"])
  {
    previewContent.addAttribute("Texto", result["campaign"]["content_body"]);
  }
  if(result["campaign_image_img"])
  {
    previewContent.addRawHTML(result["campaign_image_img"]);
    previewContent.addRawHTML("&nbsp;<br/>");
  }

  if(result["campaign"]["created_at"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addDateTime("Criado", result["campaign"]["created_at"]);
  }

  if(result["campaign"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["campaign"]["updated_at"]);
  }

  previewPanel.update(previewContent.render());
}


app.campaign.layout.contentPanel = new app.base.layout.ContentPanel(
  app.campaign.SECTION_NAME,
  [ new app.base.layout.ActionPanel(app.campaign.SECTION_NAME,
      [ new app.base.layout.GridPanel(app.campaign.SECTION_NAME),
        new app.base.layout.FormPanel(app.campaign.SECTION_NAME, null, { fileUpload: true }) ]),
    new app.base.layout.PreviewPanel(app.campaign.SECTION_NAME) ]
);

app.campaign.layout.formPanel = Ext.getCmp(app.campaign.SECTION_NAME + '-form-panel');
app.campaign.layout.formPanel.fileUpload = true;
app.campaign.layout.formPanel.add(
[
  new app.base.form.TextField(app.campaign.SECTION_NAME, 
    'campaign[name]', "Nome",
    { allowBlank: false }),
  new app.base.form.ComboBox(app.campaign.SECTION_NAME,
    'campaign[campaign_template_id]', "Template",
    { store: app.base.data.campaignTemplateStore,
      valueNotFoundText: '', width: 300, allowBlank: false
    }),
  new app.base.form.ComboBox(app.campaign.SECTION_NAME,
    'campaign[periodicity]', "Periodicidade",
    { store: new app.base.data.PairStore({ data: [
      [       '0', "INDEFINIDO" ],
      [   '86400', "DIÁRIO" ],
      [  '604800', "SEMANAL" ],
      [ '1296000', "QUINZENAL" ],
      [ '2629744', "MENSAL" ] ] }), valueNotFoundText: '', width: 200, allowBlank: false
    }),
  new app.base.form.TextField(app.campaign.SECTION_NAME, 
    'campaign[content_title]', "Conteúdo título"),
  new app.base.form.TextArea(app.campaign.SECTION_NAME, 
    'campaign[content_subtitle]', "Conteúdo subtítulo"),
  new app.base.form.TextArea(app.campaign.SECTION_NAME, 
    'campaign[content_body]', "Conteúdo texto"),

  new app.base.form.TextField(app.campaign.SECTION_NAME, 
    'campaign_image', "Conteúdo imagem",
    { inputType: 'file' }),
  new app.base.form.DisplayField(app.campaign.SECTION_NAME, 
    'campaign_image_img', null,
    { id: app.campaign.SECTION_NAME + '-campaign-image-viewer' }),
  new app.base.form.Checkbox(app.campaign.SECTION_NAME, 
    'campaign_image_delete', "Remover conteúdo imagem?", 'yes'),

  new app.base.form.FieldSet(app.campaign.SECTION_NAME, 
    'containers', "Contâineres", []),
  new app.base.form.RadioGroup(app.campaign.SECTION_NAME,
    'campaign_enabled', "Ativo?", [
      [ "Sim", "Sim" ], 
      [ "Não", "Não" ] ], { columns: 10, allowBlank: false })
]);

// unused select button
Ext.getCmp('campaign-select-button').disable();
Ext.getCmp('campaign-grid-panel').getSelectionModel().singleSelect = true;

app.campaign.containerLastUpdate = new Date();

app.campaign.layout.formPanel.on('activate', function()
{
  var containerUpdated = (Math.abs(app.campaign.containerLastUpdate.getElapsed(app.base.data.containerStore.lastUpdate)) > 0);

  if(containerUpdated)
  {
    var containerSet = Ext.getCmp('campaign-containers-set');
    var checkboxGroup = new app.base.form.StoreCheckboxGroup(
      app.campaign.SECTION_NAME, 'containers', app.base.data.containerStore,
      { columns: 3 });
    containerSet.removeAll();
    containerSet.add(checkboxGroup);
    containerSet.doLayout();
    app.campaign.containerLastUpdate = app.base.data.containerStore.lastUpdate;
  }
});


app.campaign.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.campaignStore.load();
});



Ext.namespace('app.campaign.action');

app.campaign.action.showPreview = function()
{
  var selected = app.base.action.grid.selected(app.campaign.SECTION_NAME);

  if(selected==undefined) { selected = null; }
  if(selected==null)
  {
    Ext.Msg.alert("Nenhum item selecionado");
    return false;
  }

  window.open("/campaign/preview?id=" + selected.id, "preview");
}


app.campaign.layout.gridPanel = Ext.getCmp(app.campaign.SECTION_NAME + '-grid-panel');
app.campaign.layout.gridPanelTopbar = app.campaign.layout.gridPanel.getTopToolbar();
app.campaign.layout.gridPanelTopbar.add('-',
  new app.base.layout.Button(app.campaign.SECTION_NAME,
    'preview', "Visualizar", 'eye', function() {
    app.campaign.action.showPreview();
  })
);
