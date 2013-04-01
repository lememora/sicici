Ext.namespace('app.boot.layout');

app.boot.layout.loadMask = null;

Ext.onReady(function()
{
  app.boot.layout.loadMask = new Ext.LoadMask(Ext.getBody(),
  {
    //msg: "Loading...",
    removeMask: true
  });

  app.boot.layout.loadMask.show();    

  (function()
  {
    app.boot.layout.loadMask.hide();

    var _firstGrid = Ext.getCmp(app[(app.SECTIONS[0])].SECTION_NAME + '-grid-panel');
    if(_firstGrid!=undefined) {  _firstGrid.getStore().load(); }

  }).defer(app.base.SECTIONS_TOTAL * app.base.SECTION_REGISTER_TIME);

  for(var j=0; j<app.base.SECTIONS_TOTAL; j++)
  {
    app.viewport.action.registerSection(app.SECTIONS[j], j * app.base.SECTION_REGISTER_TIME);
  }

  app.viewport.layout.viewport = new app.viewport.layout.Viewport();
  app.viewport.action.setUsername(app.AUTHENTICATED_USERNAME || "");
});
