Ext.namespace('app.contact');

app.contact.currentId = null;

app.contact.SECTION_NAME  = 'contact';
app.contact.SECTION_TITLE = "Contatos";
app.contact.COLUMNS = [
{
  name: 'individual[id]',
  header: "ID",
  hidden: true,
  sortable: true
},{
/* visible */
  name: 'individual[name]',
  header: "Nome",
  sortable: true,
  width: 250
},{
  name: 'subscriber[email]',
  header: "Email",
  renderer: app.base.layout.rendererForEmail,
  sortable: true
},{
  name: 'organization[name]',
  header: "Empresa",
  sortable: true
},{
  name: 'individual[prefered_phone]',
  header: "Telefone Preferencial",
  sortable: true
},{
  name: 'campaign_dispatches',
  header: "@Enviados",
  hidden: true
},{
  name: 'subscriber[bounces]',
  header: "@Retornados",
  sortable: true,
  hidden: true
},{
/* alphabetical */
  name: 'personal_activity_names',
  header: "Área de Atuação",
  hidden: true
},{
  name: 'individual[updated_at]',
  header: "Atualizado",
  hidden: true,
  sortable: true
},{
  name: 'individual_localizations[home][district]',
  header: "Bairro/Distrito (Residencial)",
  hidden: true
},{
  name: 'job_position',
  header: "Cargo",
  hidden: true
},{
  name: 'individual_localizations[home][city]',
  header: "Cidade (Residencial)",
  hidden: true
},{
  name: 'individual_localizations[home][code]',
  header: "Código Postal (Residencial)",
  hidden: true
},{
  name: 'container_names',
  header: "Contâineres",
  hidden: true
},{
  name: 'individual[created_at]',
  header: "Criado",
  width: 150,
  hidden: true,
  sortable: true
},{
  name: 'individual[birthdate]',
  header: "Data de Nascimento",
  hidden: true,
  sortable: true
},{
  name: 'subscriber[unsubscribed]',
  header: "Descadastrado?",
  sortable: true,
  renderer: app.base.layout.rendererForBoolean,
  hidden: true
},{
  name: 'individual[document]',
  header: "Documento",
  hidden: true,
  sortable: true
},{
  name: 'individual_localizations[home][address]',
  header: "Endereço (Residencial)",
  hidden: true
},{
  name: 'individual_localizations[home][state]',
  header: "Estado (Residencial)",
  hidden: true
},{
  name: 'individual[citizenship_country]',
  header: "Nacionalidade",
  hidden: true,
  sortable: true
},{
  name: 'individual_localizations[home][country]',
  header: "País (Residencial)",
  hidden: true
},{
  name: 'subscriber[rejected]',
  header: "Recusado?",
  sortable: true,
  renderer: app.base.layout.rendererForBoolean,
  hidden: true
},{
  name: 'individual[gender]',
  header: "Sexo",
  hidden: true,
  sortable: true
},{
  name: 'individual_connections[phone_mobile]',
  header: "Telefone Celular",
  hidden: true
},{
  name: 'individual_connections[phone_fax]',
  header: "Telefone Fax",
  hidden: true
},{
  name: 'individual_connections[phone_home]',
  header: "Telefone Residencial",
  hidden: true
},{
  name: 'individual_connections[skype]',
  header: "Skype",
  hidden: true
},{
/*
  name: 'individual_connections[website]',
  header: "Home-Page (Pessoa)",
  hidden: true
},{
*/
  name: 'organization_connections[website]',
  header: "Home-Page",
  hidden: true
},{
  name: 'subscriber[validated]',
  header: "Validado?",
  sortable: true,
  renderer: app.base.layout.rendererForBoolean,
  hidden: true
}];

app.contact.PHONE_OPTIONS = [
  { id: 'contact-individual-connections-phone-mobile-input',     tag: "(cel)"     },
  { id: 'contact-individual-connections-phone-home-input',       tag: "(res)"     },
  { id: 'contact-individual-connections-phone-fax-input',        tag: "(res/fax)" },
  { id: 'contact-organization-connections-phone-business-input', tag: "(com)"     },
  { id: 'contact-organization-connections-phone-fax-input',      tag: "(com/fax)" },
  { id: 'contact-organization-connections-phone-mobile-input',   tag: "(com/cel)" }
];


Ext.namespace('app.contact.layout');

app.contact.layout.previewContent = function(result)
{
  var previewPanel = Ext.getCmp(app.contact.SECTION_NAME + '-preview-panel');
  var previewContent = new app.base.layout.PreviewContent();

  previewContent.addTitle(result["individual"]["name"]);

  if(result["organization"]["name"])
  {
    var employment = new Array();
    if(result["job_position"]) { employment.push(result["job_position"]); }
    employment.push(result["organization"]["name"]);
    previewContent.addSubtitle(employment.join(", "));
  }

  if(result["container_names"])
  {
    previewContent.addTags(result["container_names"].split(','));
  }

  if(result["subscriber"]["email"])
  {
    previewContent.addEmail(result["subscriber"]["email"]);
    previewContent.addRawHTML("&nbsp;<br/>");
  }

  if(result["individual"]["birthdate"])
  {
    previewContent.addDate("Aniversário", result["individual"]["birthdate"]);
  }
  if(result["individual"]["gender"])
  {
    previewContent.addGender("Sexo", result["individual"]["gender"]);
  }
  if(result["individual_citizenship_country"])
  {
    previewContent.addAttribute("Nacionalidade", result["individual_citizenship_country"]);
  }
  if(result["individual"]["document"])
  {
    previewContent.addAttribute("Documento", result["individual"]["document"]);
  }
  if(result["personal_activity_names"])
  {
    previewContent.addAttribute("Atuação", result["personal_activity_names"]);
  }

  previewContent.addConnections(
    result["individual_connections"],
    result["individual"]["prefered_phone"]);

  var context = null;
  var context_available = false;

  if(result["individual"]["prefered_localization_context"])
  {
    var context = result["individual"]["prefered_localization_context"]

    if(result["individual_localizations"] &&
       result["individual_localizations"][context] &&
       result["individual_localizations"][context]["address"])
    {

      previewContent.addRawHTML("<div id=\"preferred-localization-block\" style=\"display:block\">");
      previewContent.addAddress("End. Pref.<br/>(<a href=\"#\" style=\"font-size:small;\" onclick=\"app.contact.action.swapPreviewAddress();\">todos</a>)", result["individual_localizations"][context]);
      context_available = true;
      previewContent.addRawHTML("</div>");
    }
  }

  if(context_available==true)
  {
    previewContent.addRawHTML("<div id=\"individual-localizations-block\" style=\"display:none\">");
  }

  if(result["individual_localizations"] &&
     result["individual_localizations"]["business"] &&
     result["individual_localizations"]["business"]["address"])
  {
    previewContent.addAddress(
      "End. Com.", 
      result["individual_localizations"]["business"],
      context=="business");
  }

  if(result["organization_localizations"] &&
     result["organization_localizations"]["office"] &&
     result["organization_localizations"]["office"]["address"])
  {
    previewContent.addAddress(
      "End. Emp.", 
      result["organization_localizations"]["office"],
      context=="office");
  }

  if(result["individual_localizations"] &&
     result["individual_localizations"]["home"] &&
     result["individual_localizations"]["home"]["address"])
  {
    previewContent.addAddress(
      "End. Res.", 
      result["individual_localizations"]["home"],
      context=="home");
  }

  if(context_available==true)
  {
    previewContent.addRawHTML("</div>");
  }

  if(result["individual"]["description"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addAttribute("Observação", result["individual"]["description"]);
  }

  if(result["individual"]["created_at"])
  {
    previewContent.addRawHTML("&nbsp;<br/>");
    previewContent.addDateTime("Criado", result["individual"]["created_at"]);
  }

  if(result["individual"]["updated_at"])
  {
    previewContent.addDateTime("Atualizado", result["individual"]["updated_at"]);
  }

  if(result["campaign_dispatches"])
  {
    previewContent.addAttribute("@Enviados", result["campaign_dispatches"]);
  }

  if(result["subscriber"]["bounces"])
  {
    previewContent.addAttribute("@Retornados", result["subscriber"]["bounces"]);
  }

  if(result["subscriber"]["validated"])
  {
    previewContent.addAttribute("Validado?", result["subscriber"]["validated"] ? "Sim" : "Não");
  }

  if(result["subscriber"]["rejected"])
  {
    previewContent.addAttribute("Recusado?", result["subscriber"]["rejected"] ? "Sim" : "Não");
  }

  if(result["subscriber"]["unsubscribed"])
  {
    previewContent.addAttribute("Descadastrado?", result["subscriber"]["unsubscribed"] ? "Sim" : "Não");
  }

  previewPanel.update(previewContent.render());
}

app.contact.layout.contentPanel = new app.base.layout.Scaffold(app.contact.SECTION_NAME);

app.contact.layout.formPanel = Ext.getCmp(app.contact.SECTION_NAME + '-form-panel');
app.contact.layout.formPanel.add([

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'subscriber', "Email", [
    new app.base.form.Hidden(app.contact.SECTION_NAME, 'subscriber[id]'),
    new app.base.form.TextField(app.contact.SECTION_NAME, 
      'subscriber[email]', "Email",
      { vtype: 'email' })
  ]),

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'individual', "Informações Pessoais", [
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual[name_first]', "Nome",
      { allowBlank: false, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual[name_last]', "Sobrenome",
      { allowBlank: false, width: 300 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual[document]', "Documento (CPF, DNI, etc.)",
      { maskRe: Ext.form.VTypes.alphanumMask, width: 200 }),
    new app.base.form.DateField(app.contact.SECTION_NAME,
      'individual[birthdate]', "Data de Nascimento"),
    new app.base.form.RadioGroup(app.contact.SECTION_NAME,
      'individual[gender]', "Sexo", [
        [ 'male', "Masculino" ], 
        [ 'female', "Feminino" ] ], { columns: 5 }),
    new app.base.form.CountryComboBox(app.contact.SECTION_NAME,
      'individual[citizenship_country]', "País de Nacionalidade") /*, too heavy!
    new app.base.form.FieldSet(app.contact.SECTION_NAME, 
      'personal_activities', "Áreas de Atuação", [
    ], { height: 150, collapsible: true, collapsed: true }) */

    /*
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual_connections[website]', "Home-Page",
      { width: 400 })
      */
  ]),

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'connections', "Telefones", [
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual_connections[phone_mobile]', "Celular",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual_connections[phone_home]', "Residencial",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual_connections[phone_fax]', "Fax",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'individual_connections[skype]', "Skype",
      { width: 200 })
  ]),

  new app.base.form.LocalizationFieldSet(app.contact.SECTION_NAME, 
    'individual_localizations[home]', "Endereço Residencial"),

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'organization', "Empresa", [
    new app.base.form.Hidden(app.contact.SECTION_NAME, 'organization[id]'),
    new app.base.form.ComboBox(app.contact.SECTION_NAME, 
      'organization[name]', "Nome"),
    new app.base.form.TextField(app.contact.SECTION_NAME, 
      'job_position', "Cargo",
      { width: 400 }),
    new app.base.form.TextField(app.contact.SECTION_NAME, 
      'organization[document]', "Documento (CNPJ, CIF, etc.)",
      { width: 200 }), /* too heavy
    new app.base.form.FieldSet(app.contact.SECTION_NAME, 
      'business_activities', "Áreas de Atuação", [
    ], { height: 150, collapsible: true, collapsed: true }), */
    new app.base.form.LocalizationFieldSet(app.contact.SECTION_NAME,
      'organization_localizations[office]'),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'organization_connections[phone_business]', "Telefone Comercial",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'organization_connections[phone_fax]', "Telefone Fax",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'organization_connections[phone_mobile]', "Telefone Celular",
      { maskRe: /[a-z0-9\(\)\+\-\s]/i, width: 200 }),
    new app.base.form.TextField(app.contact.SECTION_NAME,
      'organization_connections[website]', "Home-Page",
      { width: 400 })
  ]),

  new app.base.form.LocalizationFieldSet(app.contact.SECTION_NAME, 
    'individual_localizations[business]', "Endereço Comercial"),

  new app.base.form.TextArea(app.contact.SECTION_NAME,
    'individual[description]', "Observação",
    { width: 400 }),

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'containers', "Contâineres", [
  ], { height: 150 }),

  new app.base.form.FieldSet(app.contact.SECTION_NAME, 
    'preferences', "Preferências", [
    new app.base.form.ComboBox(app.contact.SECTION_NAME,
      'individual[prefered_phone]', "Telefone preferencial",
      { width: 200 }),
    new app.base.form.ComboBox(app.contact.SECTION_NAME,
      'individual[prefered_localization_context]', "Endereço preferencial",
      { store: new app.base.data.PairStore({ data: [
        [ 'home',     "RESIDENCIAL" ],
        [ 'business', "COMERCIAL" ],
        [ 'office',   "EMPRESA" ] ] }), width: 200
      }
    )
  ])
]);

app.contact.personalLastUpdate = new Date();
app.contact.businessLastUpdate = new Date();
app.contact.containerLastUpdate = new Date();

app.contact.layout.formPanel.on('activate', function()
{
  var organizationCombo = Ext.getCmp('contact-organization-name-combo');
  app.base.action.server.store('service/organizations',
    null, organizationCombo.getStore()
  );

  app.contact.action.enableOrganization();

  var citizenshipCountry = Ext.getCmp('contact-individual-citizenship-country-combo');
  citizenshipCountry.setValue('BR'); // default value for citizenship

  var deferTime = 0;


  /* too heavy

  var personalDeferTime = (app.base.data.personalActivityStore.getCount() * 30);
  var businessDeferTime = (app.base.data.businessActivityStore.getCount() * 30);
  var personalUpdated = (Math.abs(app.contact.personalLastUpdate.getElapsed(app.base.data.personalActivityStore.lastUpdate)) > 0);
  var businessUpdated = (Math.abs(app.contact.businessLastUpdate.getElapsed(app.base.data.businessActivityStore.lastUpdate)) > 0);

  if(personalUpdated) { deferTime += personalDeferTime; }
  if(businessUpdated) { deferTime += businessDeferTime; }

  if(deferTime > 0)
  {
    app.contact.layout.loadMask = new Ext.LoadMask(app.contact.layout.formPanel.body,
    {
      //msg: "Loading...",
      removeMask: true
    });

    app.contact.layout.loadMask.show();

    (function() { app.contact.layout.loadMask.hide(); }).defer(deferTime + 3000);
  }

  if(personalUpdated)
  {
    setTimeout(function()
    {
      var personalActivitiesSet = Ext.getCmp('contact-personal-activities-set');
      var checkboxGroup = new app.base.form.StoreCheckboxGroup(
        app.contact.SECTION_NAME, 'personal_activities', app.base.data.personalActivityStore,
        { columns: 1 });
      personalActivitiesSet.removeAll();
      personalActivitiesSet.add(checkboxGroup);
      personalActivitiesSet.doLayout();
      app.contact.personalLastUpdate = app.base.data.personalActivityStore.lastUpdate;
    }, 1000);
  }

  if(businessUpdated)
  {
    setTimeout(function()
    {
      var businessActivitiesSet = Ext.getCmp('contact-business-activities-set');
      var checkboxGroup = new app.base.form.StoreCheckboxGroup(
        app.contact.SECTION_NAME, 'business_activities', app.base.data.businessActivityStore,
        { columns: 1 });
      businessActivitiesSet.removeAll();
      businessActivitiesSet.add(checkboxGroup);
      businessActivitiesSet.doLayout();
      app.contact.businessLastUpdate = app.base.data.businessActivityStore.lastUpdate;
    }, (personalDeferTime + 2000));
  }

  */

  var containerUpdated = (Math.abs(app.contact.containerLastUpdate.getElapsed(app.base.data.containerStore.lastUpdate)) > 0);

  if(containerUpdated)
  {
    setTimeout(function()
    {
      var containerSet = Ext.getCmp('contact-containers-set');
      var checkboxGroup = new app.base.form.StoreCheckboxGroup(
        app.contact.SECTION_NAME, 'containers', app.base.data.containerStore,
        { columns: 3 });
      containerSet.removeAll();
      containerSet.add(checkboxGroup);
      containerSet.doLayout();
      app.contact.containerLastUpdate = app.base.data.containerStore.lastUpdate;
    }, deferTime);
  }
});

app.contact.layout.formPanel.on('populate', function()
{
  if((Ext.getCmp('contact-individual-id-hidden').getValue() || 0) > 0)
  {
    app.contact.action.disableOrganization();
  }  
});

app.contact.layout.containerWindow = new app.base.layout.FilterWindow(
  app.contact.SECTION_NAME, 'containers', "Contâineres",
  app.base.data.containerStore
);

app.contact.layout.activityWindow = new app.base.layout.FilterWindow(
  app.contact.SECTION_NAME, 'activities', "Áreas de Atuação",
  app.base.data.personalActivityStore
);

app.contact.layout.gridPanel = Ext.getCmp(app.contact.SECTION_NAME + '-grid-panel');
app.contact.layout.gridPanelTopbar = app.contact.layout.gridPanel.getTopToolbar();
app.contact.layout.gridPanelTopbar.add(
  '->',
  new app.base.layout.Button(app.contact.SECTION_NAME,
    'activities', "Áreas de Atuação", 'folder_star', function() {
    app.contact.layout.activityWindow.show();
  }), 
  new app.base.layout.Button(app.contact.SECTION_NAME,
    'containers', "Contâineres", 'folder_database', function() {
    app.contact.layout.containerWindow.show();
  })  
);

app.contact.layout.preferedPhoneCombo = Ext.getCmp('contact-individual-prefered-phone-combo');

Ext.iterate(app.contact.PHONE_OPTIONS, function(j)
{
  var cmp = Ext.getCmp(j.id);

  cmp.on('change', function(obj, newValue, oldValue)
  {
    if(Ext.isEmpty(oldValue)==false &&
       app.contact.layout.preferedPhoneCombo.getRawValue().indexOf(oldValue)>=0)
    {
      app.contact.layout.preferedPhoneCombo.setRawValue(newValue + " " + j.tag);
    }
  });
});

app.contact.layout.preferedPhoneCombo.on('focus', function()
{
  app.contact.action.updatePreferredTelephoneStore();
});

Ext.getCmp('contact-subscriber-email-input').on('change', function()
{
  app.contact.action.checkSubscriberEmail();
});

Ext.getCmp('contact-individual-name-first-input').on('change', function()
{
  app.contact.action.checkIndividualName();
});
Ext.getCmp('contact-individual-name-last-input').on('change', function()
{
  app.contact.action.checkIndividualName();
});

Ext.getCmp('contact-organization-name-combo').on('select', function()
{
  app.contact.action.loadOrganization();
});
Ext.getCmp('contact-organization-name-combo').on('change', function()
{
  if(this.getValue()==this.getRawValue()) // none from options or blank
  {
    app.contact.action.resetOrganization();
  }
});


Ext.namespace('app.contact.action');

app.contact.action.updatePreferredTelephoneStore = function()
{
  var prefered = Ext.getCmp('contact-individual-prefered-phone-combo');
  var phones = new Array();

  Ext.iterate(app.contact.PHONE_OPTIONS, function(j)
  {
    var value = Ext.getCmp(j.id).getValue();

    if(Ext.isEmpty(value)==false)
    { 
      value = value + " " + j.tag;
      phones.push([ value, value ]);
    }
  });

  prefered.getStore().loadData(phones);
}

app.contact.action.checkSubscriberEmail = function()
{
  var emailInput = Ext.getCmp('contact-subscriber-email-input');

  app.base.action.server.load(app.contact.SECTION_NAME,
  {
    email: emailInput.getValue()
  },
  function(result)
  { 
    var currentId = Ext.getCmp('contact-subscriber-id-hidden').getValue() || 0;
    var foundId = result.subscriber.id;

    if(currentId != foundId)
    {
      app.base.action.form.found(app.contact.SECTION_NAME, result, emailInput);
    }
  }); 
}

app.contact.action.checkIndividualName = function()
{
  var nameFirstInput = Ext.getCmp('contact-individual-name-first-input');
  var nameFirst = nameFirstInput.getValue();
  var nameLastInput = Ext.getCmp('contact-individual-name-last-input');
  var nameLast = nameLastInput.getValue();

  if(Ext.isEmpty(nameFirst) || Ext.isEmpty(nameLast)) { return false; }

  var fullName = nameFirstInput.getValue() + " " + nameLastInput.getValue();

  app.base.action.server.load(app.contact.SECTION_NAME,
  {
    name: fullName
  },
  function(result)
  { 
    var currentId = Ext.getCmp('contact-individual-id-hidden').getValue() || 0;
    var foundId = result.individual.id;

    if(currentId != foundId)
    {
      app.base.action.form.found(app.contact.SECTION_NAME, result, nameFirstInput);
    }
  }); 
}

app.contact.action.enableOrganization = function(enable)
{
  if(Ext.isDefined(enable)==false) { enable = true; }

  var organizationSet = Ext.getCmp('contact-organization-set');
  var localizationSet = Ext.getCmp('contact-organization-localizations-office-set');
  var doNotDisable = [ 'organization[id]', 'organization[name]', 'job_position' ];

  organizationSet.items.each(function(j)
  {
    if(Ext.isDefined(j.getName))
    {
      if(doNotDisable.indexOf(j.getName())<0) { enable ? j.enable() : j.disable(); }
    }
  });
  localizationSet.items.each(function(j)
  {
    if(Ext.isDefined(j.getName))
    {
      enable ? j.enable() : j.disable();
    }
  });
}

app.contact.action.disableOrganization = function()
{
  app.contact.action.enableOrganization(false);
}

app.contact.action.loadOrganization = function()
{
  var organizationCombo = Ext.getCmp('contact-organization-name-combo');
  var organizationSet = Ext.getCmp('contact-organization-set');
  var localizationSet = Ext.getCmp('contact-organization-localizations-office-set');

  app.base.action.server.load(app.organization.SECTION_NAME,
  {
    id: organizationCombo.getValue()
  },
  function(result)
  {
    if(Ext.isEmpty(result.organization.id)==false)
    {
      app.base.helper.populate(organizationSet.items, result);
      app.base.helper.populate(localizationSet.items, result);
      app.contact.action.disableOrganization();
    }
  });
}

app.contact.action.resetOrganization = function()
{
  var organizationSet = Ext.getCmp('contact-organization-set');
  var localizationSet = Ext.getCmp('contact-organization-localizations-office-set');
  var doNotReset = [ 'organization[name]' ];

  organizationSet.items.each(function(j)
  {
    if(Ext.isDefined(j.getName))
    {
      if(doNotReset.indexOf(j.getName())<0) { j.setValue(null); }
    }
  });
  localizationSet.items.each(function(j)
  {
    if(Ext.isDefined(j.getName)) { j.setValue(null); }
  });

  app.contact.action.enableOrganization();
}

app.contact.action.swapPreviewAddress = function()
{
  Ext.fly('preferred-localization-block').remove();
  Ext.fly('individual-localizations-block').show();
  return false;
}
