Ext.namespace('app.business_activity');

app.business_activity.SECTION_NAME  = 'business_activity';
app.business_activity.SECTION_TITLE = "Atuação (PJ)";
app.business_activity.SEARCH_HEAD_SECTION = true;
app.business_activity.COLUMNS = [
{
  name: 'business_activity[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'business_activity[name]',
  header: "Nome",
  sortable: true
},{
  name: 'members',
  header: "Membros",
  sortable: false
}];


Ext.namespace('app.business_activity.layout');

app.business_activity.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.business_activity.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["business_activity"]["name"]);

  if(result["members"])
  {
    previewContent.addAttribute("Membros", result["members"]);
  }

  previewPanel.update(previewContent.render());
}


app.business_activity.layout.contentPanel = new app.base.layout.Scaffold(app.business_activity.SECTION_NAME);

app.business_activity.layout.formPanel = Ext.getCmp(app.business_activity.SECTION_NAME + '-form-panel');
app.business_activity.layout.formPanel.add(
[
  new app.base.form.TextField(app.business_activity.SECTION_NAME, 
    'business_activity[name]', "Nome",
    { allowBlank: false })
]);

// unused select button
Ext.getCmp('business_activity-select-button').disable();
Ext.getCmp('business_activity-grid-panel').getSelectionModel().singleSelect = true;

// every new business_activity must update business_activity store
app.business_activity.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.businessActivityStore.load();
});
