Ext.namespace('app.campaign_job');

app.campaign_job.SECTION_NAME  = 'campaign_job';
app.campaign_job.SECTION_TITLE = "Disparo de Campanhas";
app.campaign_job.DEFAULT_SORT = 'campaign_jobs.created_at DESC';
app.campaign_job.SEARCH_HEAD_SECTION = true;
app.campaign_job.COLUMNS = [
{
  name: 'campaign_job[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
  name: 'campaign_job[subject]',
  header: "Nome",
  sortable: true
},{
  name: 'campaign_job_campaign',
  header: "Campanha"
},{
  name: 'campaign_job_status',
  header: "Status",
  sortable: true
},{
  name: 'campaign_total',
  header: "Total",
  hidden: true
},{
  name: 'campaign_sent',
  header: "Enviados",
  hidden: true
},{
  name: 'campaign_bogus',
  header: "Falhos",
  hidden: true
},{
  name: 'campaign_completed',
  header: "% Concluído"
},{
  name: 'campaign_job[scheduled]',
  header: "Agendamento",
  hidden: true
},{
  name: 'campaign_job[created_at]',
  header: "Criado",
  sortable: true
},{
  name: 'campaign_job[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
}];


Ext.namespace('app.campaign_job.layout');

app.campaign_job.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.campaign_job.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["campaign_job"]["subject"]);
  previewContent.addSubtitle(result["campaign_job_campaign"]);

  previewContent.addRawHTML("&nbsp;<br/>");

  if(result["campaign_job_status"])
  {
    previewContent.addAttribute("Status", result["campaign_job_status"]);
  }
  if(result["campaign_scheduled"])
  {
    previewContent.addDate("Agendamento", result["campaign_scheduled"]);
  }
  if(result["campaign_total"])
  {
    previewContent.addAttribute("Total", result["campaign_total"]);
  }
  if(result["campaign_sent"])
  {
    previewContent.addAttribute("Enviado", result["campaign_sent"]);
  }
  if(result["campaign_bogus"])
  {
    previewContent.addAttribute("Falhos", result["campaign_bogus"]);
  }
  if(result["campaign_completed"]!="&empty")
  {
    previewContent.addAttribute("% Concluído", result["campaign_completed"]);
  }

  if(result["campaign_job"]["created_at"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addDateTime("Criado", result["campaign_job"]["created_at"]);
  }

  if(result["campaign_job"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["campaign_job"]["updated_at"]);
  }

  previewPanel.update(previewContent.render());
}


app.campaign_job.layout.contentPanel = new app.base.layout.Scaffold(app.campaign_job.SECTION_NAME);

app.campaign_job.layout.formPanel = Ext.getCmp(app.campaign_job.SECTION_NAME + '-form-panel');
app.campaign_job.layout.formPanel.add(
[
  new app.base.form.ComboBox(app.campaign_job.SECTION_NAME,
    'campaign_job[campaign_id]', "Campanha",
    { store: app.base.data.campaignStore,
      valueNotFoundText: '', width: 300, required: true
    }),
  new app.base.form.TextField(app.campaign_job.SECTION_NAME, 
    'campaign_job[subject]', "Assunto",
    { allowBlank: false, required: true }),
  new app.base.form.DateField(app.campaign_job.SECTION_NAME,
    'campaign_job[scheduled]', "Agendamento", 
    { required: true })
]);


app.campaign_job.layout.gridPanel = Ext.getCmp('campaign_job-grid-panel');


app.campaign_job.layout.gridPanelTopbar = app.campaign_job.layout.gridPanel.getTopToolbar();
app.campaign_job.layout.gridPanelTopbar.add('-',
  new app.base.layout.Button(app.campaign_job.SECTION_NAME,
    'start', "Iniciar", 'control_play_blue', function() {
    app.campaign_job.action.start();
  }, { disabled: true }),
  new app.base.layout.Button(app.campaign_job.SECTION_NAME,
    'stop', "Parar", 'control_stop', function() {
    app.campaign_job.action.stop();
  }, { disabled: true })
);


app.campaign_job.layout.gridPanel.getSelectionModel().on('selectionchange', function()
{
  var selected = app.base.action.grid.selected(app.campaign_job.SECTION_NAME);
  var job_status = selected==undefined ? null : selected.data["campaign_job_status"];
  var job_scheduled = selected==undefined ? null : selected.data["campaign_job[scheduled]"];

  var edit_button = Ext.getCmp("campaign_job-edit-button");
  var preview_edit_button = Ext.getCmp("campaign_job-preview-edit-button");
  var delete_button = Ext.getCmp("campaign_job-delete-button");

  var start_button = Ext.getCmp("campaign_job-start-button");
  var stop_button = Ext.getCmp("campaign_job-stop-button");

  (function()
  {
    if(job_status=='Novo')
    {
      start_button.enable();
      edit_button.enable();
      preview_edit_button.enable();
      delete_button.enable();
    }
    else
    {
      start_button.disable();
      edit_button.disable();
      preview_edit_button.disable();
      delete_button.disable();
    }

    if(job_status=='Executando')
    {
      stop_button.enable();
    }
    else
    {
      stop_button.disable();
    }
  }).defer(50);
});


// unused select button
Ext.getCmp('campaign_job-select-button').disable();
app.campaign_job.layout.gridPanel.getSelectionModel().singleSelect = true;


Ext.namespace('app.campaign_job.action');


app.campaign_job.action.start = function()
{
  var selected = app.base.action.grid.selected(app.campaign_job.SECTION_NAME);

  app.base.action.server.request(
    "/campaign_job/start", 
    { id: selected.id },
    function()
    {
      app.campaign_job.layout.gridPanel.getStore().reload();
    }
  );
}

app.campaign_job.action.stop = function()
{
  var selected = app.base.action.grid.selected(app.campaign_job.SECTION_NAME);

  app.base.action.server.request(
    "/campaign_job/stop", 
    { id: selected.id },
    function()
    {
      app.campaign_job.layout.gridPanel.getStore().reload();
    }
  );
}

app.campaign_job.layout.testWindow = null;


Ext.namespace('app.campaign_job.action');

app.campaign_job.action.test = function(id, email)
{
  app.base.action.server.request(
    "/campaign_job/test",
    { campaign_job_id: id, email: email },
    function(data)
    {
      return true;
    }
  );
}

app.campaign_job.action.showTest = function()
{
  var selected = app.base.action.grid.selected(app.campaign_job.SECTION_NAME);

  if(selected==undefined) { selected = null; }
  if(selected==null)
  {
    Ext.Msg.alert("Nenhum item selecionado");
    return false;
  }

  if(app.campaign_job.layout.testWindow==null)
  {
    app.campaign_job.layout.testWindow = new Ext.Window(
    {
      id: app.campaign_job.SECTION_NAME + '-test-window',
      layout: 'fit',
      width: 300,
      height:100,
      closeAction: 'hide',
      plain: true,
      items: new Ext.FormPanel(
      {
        items: [
          new Ext.form.TextField(
          {
            id: app.campaign_job.SECTION_NAME + '-test-email',
            fieldLabel: "Email"
          })
        ],
        buttons: [
          new app.base.layout.Button(app.campaign_job.SECTION_NAME,
            'test-submit', "Enviar", 'email_go', function()
            {
              var emailInput = Ext.getCmp('campaign_job-test-email');
              app.campaign_job.action.test(selected.id, emailInput.getValue());
              Ext.getCmp('campaign_job-test-window').hide();
              return true;
            }
          )
        ]
      })
    });
  }

  app.campaign_job.layout.testWindow.on('beforeshow', function()
  {
    var viewport = Ext.getCmp('viewport');
    this.setPosition(195, viewport.getHeight() - app.campaign_job.layout.testWindow.getHeight() - 60);
  });

  app.campaign_job.layout.testWindow.show();
}

app.campaign_job.layout.gridPanelTopbar = app.campaign_job.layout.gridPanel.getTopToolbar();
app.campaign_job.layout.gridPanelTopbar.add('-',
  new app.base.layout.Button(app.campaign_job.SECTION_NAME,
    'test', "Testar", 'email', function() {
    app.campaign_job.action.showTest();
  })
);
