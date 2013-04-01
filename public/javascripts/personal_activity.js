Ext.namespace('app.personal_activity');

app.personal_activity.SECTION_NAME  = 'personal_activity';
app.personal_activity.SECTION_TITLE = "Atuação (PF)";
app.personal_activity.SEARCH_HEAD_SECTION = true;
app.personal_activity.COLUMNS = [
{
  name: 'personal_activity[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'personal_activity[name]',
  header: "Nome",
  sortable: true
},{
  name: 'members',
  header: "Membros",
  sortable: false
}];


Ext.namespace('app.personal_activity.layout');

app.personal_activity.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.personal_activity.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["personal_activity"]["name"]);

  if(result["members"])
  {
    previewContent.addAttribute("Membros", result["members"]);
  }

  previewPanel.update(previewContent.render());
}


app.personal_activity.layout.contentPanel = new app.base.layout.Scaffold(app.personal_activity.SECTION_NAME);

app.personal_activity.layout.formPanel = Ext.getCmp(app.personal_activity.SECTION_NAME + '-form-panel');
app.personal_activity.layout.formPanel.add(
[
  new app.base.form.TextField(app.personal_activity.SECTION_NAME, 
    'personal_activity[name]', "Nome",
    { allowBlank: false })
]);

// unused select button
Ext.getCmp('personal_activity-select-button').disable();
Ext.getCmp('personal_activity-grid-panel').getSelectionModel().singleSelect = true;

// every new personal_activity must update personal_activity store
app.personal_activity.layout.formPanel.getForm().on('actioncomplete', function()
{
  app.base.data.personalActivityStore.load();
});
