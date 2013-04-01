Ext.namespace('app.history');

app.history.SECTION_NAME  = 'history';
app.history.SECTION_TITLE = "Históricos";
app.history.SEARCH_HEAD_SECTION = true;
app.history.DEFAULT_SORT = "created_at DESC";
app.history.COLUMNS = [
{
  name: 'acl_history[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'acl_history_action',
  header: "Ação",
  hidden: true
},{
  name: 'acl_user_username',
  header: "Usuário",
  sortable: false
},{
  name: 'acl_role_name',
  header: "Seção",
  sortable: false,
  hidden: true
},{
  name: 'acl_history[message]',
  header: "Mensagem",
  sortable: false,
  width: 300
},{
  name: 'acl_history[created_at]',
  header: "Criado",
  sortable: true
}];


Ext.namespace('app.history.layout');

app.history.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.history.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addAttribute("Ação", result["acl_history_action"]);
  previewContent.addAttribute("Usuário", result["acl_user_username"]);
  previewContent.addAttribute("Seção", result["acl_role_name"]);
  previewContent.addAttribute("Mensagem", result["acl_history"]["message"]);
  previewContent.addDateTime("Criado", result["acl_history"]["created_at"]);

  previewPanel.update(previewContent.render());
}


// app.history.layout.contentPanel = new app.base.layout.Scaffold(app.history.SECTION_NAME);
app.history.layout.contentPanel = new app.base.layout.ContentPanel(
  app.history.SECTION_NAME,
  [ new app.base.layout.ActionPanel(app.history.SECTION_NAME,
      [ new app.base.layout.GridPanel(app.history.SECTION_NAME),
        new app.base.layout.FormPanel(app.history.SECTION_NAME, null) ]),
    new app.base.layout.PreviewPanel(app.history.SECTION_NAME) ]
);

// unused select button
Ext.getCmp('history-select-button').disable();
Ext.getCmp('history-grid-panel').getSelectionModel().singleSelect = true;

// unused add button
Ext.getCmp('history-add-button').disable();
