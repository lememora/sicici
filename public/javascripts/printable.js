Ext.namespace('app.printable');

app.printable.SECTION_NAME  = 'printable';
app.printable.SECTION_TITLE = "Impressões";
app.printable.SEARCH_HEAD_SECTION = true;
app.printable.COLUMNS = [
{
  name: 'printable[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'printable[name]',
  header: "Nome",
  sortable: true
},{
  name: 'printable_template',
  header: "Template",
  sortable: true
},{
  name: 'printable[created_at]',
  header: "Criado",
  sortable: true
},{
  name: 'printable[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.printable.layout');

app.printable.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.printable.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["printable"]["name"]);
  previewContent.addSubtitle(result["printable_template"]);

  if(result["container_names"])
  {
    previewContent.addTags(result["container_names"].split(','));
  }

  if(result["printable"]["created_at"])
  {
    previewContent.addDateTime("Criado", result["printable"]["created_at"]);
  }

  if(result["printable"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["printable"]["updated_at"]);
  }

  previewPanel.update(previewContent.render());
}


app.printable.layout.contentPanel = new app.base.layout.Scaffold(app.printable.SECTION_NAME);

app.printable.layout.formPanel = Ext.getCmp(app.printable.SECTION_NAME + '-form-panel');
app.printable.layout.formPanel.add(
[
  new app.base.form.TextField(app.printable.SECTION_NAME, 
    'printable[name]', "Nome",
    { allowBlank: false }),
  new app.base.form.ComboBox(app.printable.SECTION_NAME,
    'printable[printable_template_id]', "Template",
    { store: app.base.data.printableTemplateStore,
      valueNotFoundText: '', width: 300
    }),
  new app.base.form.FieldSet(app.printable.SECTION_NAME, 
    'containers', "Contâineres", [])
]);

// unused select button
Ext.getCmp('printable-select-button').disable();
Ext.getCmp('printable-grid-panel').getSelectionModel().singleSelect = true;


app.printable.layout.formPanel.on('activate', function()
{
  var containerSet = Ext.getCmp('printable-containers-set');
  var checkboxGroup = new app.base.form.StoreCheckboxGroup(
    app.printable.SECTION_NAME, 'containers', app.base.data.containerStore,
    { columns: 3 });
  containerSet.removeAll();
  containerSet.add(checkboxGroup);
  containerSet.doLayout();
});


app.printable.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.printableStore.load();
});


app.printable.layout.nameInput = Ext.getCmp('printable-printable-name-input');
app.printable.layout.templateInput = Ext.getCmp('printable-printable-printable-template-id-combo');
