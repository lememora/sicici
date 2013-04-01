class Notifier < ActionMailer::Base
  def subscriber_request_validation(subscriber)
    recipients subscriber.email
    from "#{APP_CONFIG["mail_from_name"]} <#{APP_CONFIG["mail_from_username"]}@#{APP_CONFIG["mail_from_domain"]}>"
    subject "Novo Cadastro"
    sent_on Time.now

    subscriber_h = subscriber.hashmap
    individual_h = subscriber.individual.hashmap
    employment = subscriber.individual.employment
    organization_h = nil
    organization_h = employment.organization.hashmap if employment and employment.organization

    body :subscriber => subscriber_h, 
         :individual => individual_h,
         :organization => organization_h

    content_type "text/html"
  end

  def subscriber_request_update(subscriber, event=nil)
    recipients subscriber.email
    from "#{APP_CONFIG["mail_from_name"]} <#{APP_CONFIG["mail_from_username"]}@#{APP_CONFIG["mail_from_domain"]}>"
    subject "Atualizar Cadastro"
    sent_on Time.now
    body :subscriber => subscriber.hashmap,
         :permalink => (event ? event.permalink : nil)
    content_type "text/html"
  end

  def subscriber_request_confirmation(subscriber, event)
    recipients subscriber.email
    from "#{APP_CONFIG["mail_from_name"]} <#{APP_CONFIG["mail_from_username"]}@#{APP_CONFIG["mail_from_domain"]}>"
    subject "Confirmar Inscrição"
    sent_on Time.now

    event_h = event.hashmap
    subscriber_h = subscriber.hashmap
    individual_h = subscriber.individual.hashmap
    employment = subscriber.individual.employment
    organization_h = nil
    organization_h = employment.organization.hashmap if employment and employment.organization
    has_subscription = subscriber.events.include?(event)

    body :subscriber => subscriber_h, 
         :individual => individual_h,
         :organization => organization_h,
         :event => event_h,
         :has_subscription => has_subscription

    content_type "text/html"
  end

  def campaign_test(template, to, subject="Mensagem de Teste", data={})
    template = ApplicationHelper.generate_permalink(template).gsub(/-/,'_')
    template = "campaign_template/#{template}"
    template = TemplateHelper.render_view(template, data)
    rhtml = ERB.new(template)
    data = Hash.new
    subscriber = Subscriber.last(:include => :individual)
    data["subscriber"] = subscriber.attributes
    data["individual"] = subscriber.individual.attributes
    mail_body = TemplateHelper.render_rhtml(rhtml, data)

    recipients to
    from "#{APP_CONFIG["mail_from_name"]} <#{APP_CONFIG["mail_from_username"]}@#{APP_CONFIG["mail_from_domain"]}>"
    subject subject
    sent_on Time.now
    body :body => mail_body
    content_type "text/html"

    return true
  end
end
