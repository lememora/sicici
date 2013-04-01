Ext.namespace('app.organization');

app.organization.SECTION_NAME  = 'organization';
app.organization.SECTION_TITLE = "Empresas";
app.organization.COLUMNS = [
{
  name: 'organization[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'organization[name]',
  header: "Nome",
  sortable: true
},{
  name: 'organization[document]',
  header: "Documento",
  hidden: true,
  sortable: true
},{
  name: 'business_activity_names',
  header: "Área de Atuação",
  hidden: true
},{
  name: 'organization_connections[phone_business]',
  header: "Telefone Comercial",
  hidden: true
},{
  name: 'organization_connections[phone_fax]',
  header: "Telefone Fax",
  hidden: true
},{
  name: 'organization_connections[phone_mobile]',
  header: "Telefone Celular",
  hidden: true
},{
  name: 'organization_connections[website]',
  header: "Home-Page",
  hidden: true
/*},{
  name: 'organization_localizations[office][country]',
  header: "País",
  hidden: true
},{
  name: 'organization_localizations[office][code]',
  header: "Código Postal",
  hidden: true
},{
  name: 'organization_localizations[office][state]',
  header: "Estado",
  hidden: true
},{
  name: 'organization_localizations[office][city]',
  header: "Cidade",
  hidden: true
},{
  name: 'organization_localizations[office][district]',
  header: "Bairro/Distrito",
  hidden: true
},{
  name: 'organization_localizations[office][address]',
  header: "Endereço",
  hidden: true
*/
},{
  name: 'organization[created_at]',
  header: "Criado",
  hidden: false,
  sortable: true
},{
  name: 'organization[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.organization.layout');

app.organization.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.organization.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["organization"]["name"]);

  if(result["organization"]["document"])
  {
    previewContent.addAttribute("Documento", result["organization"]["document"]);
  }
  if(result["business_activity_names"])
  {
    previewContent.addAttribute("Atuação", result["business_activity_names"]);
  }

  previewContent.addConnections(result["organization_connections"]);

  if(result["organization_localizations"] &&
     result["organization_localizations"]["office"] &&
     result["organization_localizations"]["office"]["address"])
  {
    previewContent.addAddress("Endereço", 
      result["organization_localizations"]["office"]);
  }

  if(result["organization"]["description"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addAttribute("Observação", result["organization"]["description"]);
  }

  if(result["organization"]["created_at"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addDateTime("Criado", result["organization"]["created_at"]);
  }

  if(result["organization"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["organization"]["updated_at"]);
  }

  previewPanel.update(previewContent.render());
}


app.organization.layout.contentPanel = new app.base.layout.Scaffold(app.organization.SECTION_NAME);

app.organization.layout.formPanel = Ext.getCmp(app.organization.SECTION_NAME + '-form-panel');
app.organization.layout.formPanel.add(
[
  new app.base.form.TextField(app.organization.SECTION_NAME, 
    'organization[name]', "Nome",
    { allowBlank: false }),
  new app.base.form.TextField(app.organization.SECTION_NAME, 
    'organization[document]', "Documento (CNPJ, CIF, etc.)",
    { width: 200 }), /* too heavy
  new app.base.form.FieldSet(app.organization.SECTION_NAME, 
    'business_activities', "Áreas de Atuação", [
  ], { height: 150, collapsible: true, collapsed: true }), */
  new app.base.form.LocalizationFieldSet(app.organization.SECTION_NAME,
    'organization_localizations[office]'),
  new app.base.form.TextField(app.organization.SECTION_NAME,
    'organization_connections[phone_business]', "Telefone Comercial",
    { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
  new app.base.form.TextField(app.organization.SECTION_NAME,
    'organization_connections[phone_fax]', "Telefone Fax",
    { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
  new app.base.form.TextField(app.organization.SECTION_NAME,
    'organization_connections[phone_mobile]', "Telefone Celular",
    { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
  new app.base.form.TextArea(app.organization.SECTION_NAME,
    'organization[description]', "Observação",
    { width: 400 }),
  new app.base.form.TextField(app.organization.SECTION_NAME,
    'organization_connections[website]', "Home-Page",
    { width: 400 })
]);

// unused select button
Ext.getCmp('organization-select-button').disable();
Ext.getCmp('organization-grid-panel').getSelectionModel().singleSelect = true;


app.organization.layout.activityWindow = new app.base.layout.FilterWindow(
  app.organization.SECTION_NAME, 'activities', "Áreas de Atuação",
  app.base.data.businessActivityStore
);


app.organization.businessLastUpdate = new Date();

app.organization.layout.formPanel.on('activate', function()
{
  var deferTime = 0;

  /* too heavy

  var businessDeferTime = (app.base.data.businessActivityStore.getCount() * 30);
  var businessUpdated = (Math.abs(app.organization.businessLastUpdate.getElapsed(app.base.data.businessActivityStore.lastUpdate)) > 0);

  if(businessUpdated) { deferTime += businessDeferTime; }

  if(deferTime > 0)
  {
    app.organization.layout.loadMask = new Ext.LoadMask(app.organization.layout.formPanel.body,
    {
      //msg: "Loading...",
      removeMask: true
    });

    app.organization.layout.loadMask.show();

    (function() { app.organization.layout.loadMask.hide(); }).defer(deferTime);

    setTimeout(function()
    {
      var businessActivitiesSet = Ext.getCmp('organization-business-activities-set');
      var checkboxGroup = new app.base.form.StoreCheckboxGroup(
        app.organization.SECTION_NAME, 'business_activities', app.base.data.businessActivityStore,
        { columns: 1 });
      businessActivitiesSet.removeAll();
      businessActivitiesSet.add(checkboxGroup);
      businessActivitiesSet.doLayout();
      app.organization.businessLastUpdate = app.base.data.businessActivityStore.lastUpdate;
    }, 1000);
  }

  */
});


app.organization.layout.gridPanel = Ext.getCmp(app.organization.SECTION_NAME + '-grid-panel');
app.organization.layout.gridPanelTopbar = app.organization.layout.gridPanel.getTopToolbar();
app.organization.layout.gridPanelTopbar.add(
  '->',
  new app.base.layout.Button(app.organization.SECTION_NAME,
    'activities', "Áreas de Atuação", 'folder_star', function() {
    app.organization.layout.activityWindow.show();
  })
);
