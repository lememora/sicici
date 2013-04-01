Ext.namespace('app.user');

app.user.SECTION_NAME  = 'user';
app.user.SECTION_TITLE = "Usuários";
app.user.SEARCH_HEAD_SECTION = true;
app.user.COLUMNS = [
{
  name: 'acl_user[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'acl_user[username]',
  header: "Usuário",
  sortable: true
},{
  name: 'acl_user_enabled',
  header: "Habilitado"
}];


Ext.namespace('app.user.layout');

app.user.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.user.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["acl_user"]["username"]);

  if(result["permissions"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addRawHTML(result["permissions"]);
    previewContent.addRawHTML("&nbsp;<br/>");
  }

  if(result["acl_user_enabled"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addAttribute("Habilitado?", result["acl_user_enabled"]);
  }

  previewPanel.update(previewContent.render());
}


// app.user.layout.contentPanel = new app.base.layout.Scaffold(app.user.SECTION_NAME);
app.user.layout.contentPanel = new app.base.layout.ContentPanel(
  app.user.SECTION_NAME,
  [ new app.base.layout.ActionPanel(app.user.SECTION_NAME,
      [ new app.base.layout.GridPanel(app.user.SECTION_NAME),
        new app.base.layout.FormPanel(app.user.SECTION_NAME, null) ]),
    new app.base.layout.PreviewPanel(app.user.SECTION_NAME) ]
);

app.user.layout.formPanel = Ext.getCmp(app.user.SECTION_NAME + '-form-panel');
app.user.layout.formPanel.add(
[
  new app.base.form.TextField(app.user.SECTION_NAME, 
    'acl_user[username]', "Usuário",
    { allowBlank: false }),
  new app.base.form.TextField(app.user.SECTION_NAME, 
    'acl_user[password]', "Senha",
    { maskRe: /[a-z0-9\-]/i, inputType: 'password' }),
  new app.base.form.RadioGroup(app.user.SECTION_NAME,
    'acl_user_enabled', "Habilitado", [
      [ true, "Sim" ], 
      [ false, "Não" ] ], { columns: 10, allowBlank: false }),
  new app.base.form.FieldSet(app.user.SECTION_NAME, 
    'roles', "Permissões", [
  ])
]);


Ext.namespace('app.user.action');

app.user.set_role_is_busy = false;

app.user.action.setRole = function(group, name, value)
{
  if(app.user.set_role_is_busy==true) { return false; }

  app.user.set_role_is_busy = true;

  var spl = name.replace("roles","").replace(/[\[\]]/g, "").split(/-/);
  var id = spl[0];
  var action = spl[1];

  var f_a = null;
  var f_r = null;
  var f_w = null;

  group.items.each(function(f)
  {
    var f_spl = f.getName().replace("roles","").replace(/[\[\]]/g, "").split(/-/);
    var f_id = f_spl[0];
    var f_action = f_spl[1];

    if(id == f_id)
    {
      if(f_action=='a') { f_a = f; }
      if(f_action=='r') { f_r = f; }
      if(f_action=='w') { f_w = f; }
    }
  });

  if(action=='a')
  {
    f_r.setValue(value);
    f_w.setValue(value);
  }
  else if(action=='r')
  {
    f_a.setValue(f_r.getValue() && f_w.getValue());
    if(f_r.getValue()==false) { f_w.setValue(false); }
  }
  else if(action=='w')
  {
    if(f_w.getValue()==true) { f_r.setValue(true); }
    f_a.setValue(f_r.getValue() && f_w.getValue());
  }

  app.user.set_role_is_busy = false;
}

app.user.rolesLoaded = false;

app.user.layout.formPanel.on('activate', function()
{
  if(app.user.rolesLoaded==false)
  {
    var roleSet = Ext.getCmp('user-roles-set');
    var checkboxGroup = new app.base.form.StoreCheckboxGroup(
      app.user.SECTION_NAME, 'roles', app.base.data.roleStore,
      { columns: 3, width: 800 });
    roleSet.removeAll();
    roleSet.add(checkboxGroup);
    roleSet.doLayout();
    app.user.rolesLoaded = true;

    checkboxGroup.items.each(function(f)
    {
      f.on('check', function(t, c)
      {
        app.user.action.setRole(checkboxGroup, t.getName(), c)
      });
    });
  }
});


// unused select button
Ext.getCmp('user-select-button').disable();
Ext.getCmp('user-grid-panel').getSelectionModel().singleSelect = true;
