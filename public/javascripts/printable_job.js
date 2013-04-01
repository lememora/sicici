Ext.namespace('app.printable_job');

app.printable_job.SECTION_NAME  = 'printable_job';
app.printable_job.SECTION_TITLE = "Compilador de Impressões";
app.printable_job.SEARCH_HEAD_SECTION = true;
app.printable_job.COLUMNS = [
{
  name: 'printable_job[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'printable_job[created_at]',
  header: "Criado",
  sortable: true
},{
  name: 'printable_job_printable',
  header: "Impressão",
  sortable: false
},{
  name: 'printable_job[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.printable_job.layout');

app.printable_job.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.printable_job.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["printable_job_printable"]);

  previewContent.addRawHTML("&nbsp;<br/>");

  if(result["printable_job_total"])
  {
    previewContent.addAttribute("Total", result["printable_job_total"]);
    previewContent.addRawHTML("&nbsp;<br/>");
  }

  if(result["printable_job"]["created_at"])
  {
    previewContent.addDateTime("Criado", result["printable_job"]["created_at"]);
  }

  previewPanel.update(previewContent.render());
}


app.printable_job.layout.contentPanel = new app.base.layout.Scaffold(app.printable_job.SECTION_NAME);

app.printable_job.layout.formPanel = Ext.getCmp(app.printable_job.SECTION_NAME + '-form-panel');
app.printable_job.layout.formPanel.add(
[
  new app.base.form.ComboBox(app.printable_job.SECTION_NAME,
    'printable_job[printable_id]', "Impressão",
    { store: app.base.data.printableStore,
      valueNotFoundText: '', width: 300
    })
]);


app.printable_job.layout.gridPanel = Ext.getCmp('printable_job-grid-panel');


app.printable_job.layout.gridPanelTopbar = app.printable_job.layout.gridPanel.getTopToolbar();
app.printable_job.layout.gridPanelTopbar.add('-',
  new app.base.layout.Button(app.printable_job.SECTION_NAME,
    'download', "Download", 'page_save', function() {
    app.printable_job.action.download();
  })
);


app.printable_job.layout.gridPanel.getSelectionModel().on('selectionchange', function()
{
  var selected = app.base.action.grid.selected(app.printable_job.SECTION_NAME);
  var job_status = selected==undefined ? null : selected.data["printable_job_status"];
  var job_scheduled = selected==undefined ? null : selected.data["printable_job[scheduled]"];

  var edit_button = Ext.getCmp("printable_job-edit-button");
  var delete_button = Ext.getCmp("printable_job-delete-button");

  var download_button = Ext.getCmp("printable_job-download-button");
});


// unused select button
Ext.getCmp('printable_job-select-button').disable();
Ext.getCmp('printable_job-grid-panel').getSelectionModel().singleSelect = true;


Ext.namespace('app.printable_job.action');


app.printable_job.action.download = function()
{
  var selected = app.base.action.grid.selected(app.printable_job.SECTION_NAME);
  document.location="/printable_job/download?id=" + selected.id + "&" + (new Date().getTime());
}
