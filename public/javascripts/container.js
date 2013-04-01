Ext.namespace('app.container');

app.container.SECTION_NAME  = 'container';
app.container.SECTION_TITLE = "Contâineres";
app.container.SEARCH_HEAD_SECTION = true;
app.container.COLUMNS = [
{
  name: 'container[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'container[name]',
  header: "Nome",
  sortable: true
},{
  name: 'container_type',
  header: "Tipo",
  sortable: false
},{
  name: 'members',
  header: "Membros",
  sortable: false
},{
  name: 'container_public',
  header: "Público?",
  sortable: false
},{
  name: 'container_removable',
  header: "Removível?",
  sortable: false
}];


Ext.namespace('app.container.layout');

app.container.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.container.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["container"]["name"]);

  if(result["container_type"])
  {
    previewContent.addAttribute("Tipo", result["container_type"]);
  }
  if(result["container_public"])
  {
    previewContent.addAttribute("Público?", result["container_public"]);
  }
  if(result["container_removable"])
  {
    previewContent.addAttribute("Removível?", result["container_removable"]);
  }
  if(result["members"])
  {
    previewContent.addAttribute("Membros", result["members"]);
  }

  previewPanel.update(previewContent.render());
}


app.container.layout.contentPanel = new app.base.layout.Scaffold(app.container.SECTION_NAME);

app.container.layout.formPanel = Ext.getCmp(app.container.SECTION_NAME + '-form-panel');
app.container.layout.formPanel.fileUpload = true;
app.container.layout.formPanel.add(
[
  /*
  new app.base.form.ComboBox(app.container.SECTION_NAME,
    'container[container_type_id]', "Tipo",
    { store: app.base.data.containerTypeStore,
      valueNotFoundText: '', width: 300
    }),
  */
  new app.base.form.TextField(app.container.SECTION_NAME, 
    'container[name]', "Nome",
    { allowBlank: false }),
  new app.base.form.RadioGroup(app.container.SECTION_NAME,
    'container_public', "Público?", [
      [ "Sim", "Sim" ], 
      [ "Não", "Não" ] ], { allowBlank: false, columns: 10 })
]);

// unused select button
Ext.getCmp('container-select-button').disable();
Ext.getCmp('container-grid-panel').getSelectionModel().singleSelect = true;

// every new container must update container store
app.container.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.containerStore.load();
});


app.container.layout.gridPanel = Ext.getCmp('container-grid-panel');

app.container.layout.gridPanel.getSelectionModel().on('selectionchange', function()
{
  var selected = app.base.action.grid.selected(app.container.SECTION_NAME);
  var removable = selected==undefined ? null : selected.data["container_removable"];
  var delete_button = Ext.getCmp("container-delete-button");

  (function()
  {
    if(removable=="Sim")
    {
      delete_button.enable();
    }
    else
    {
      delete_button.disable();
    }
  }).defer(50);
});
