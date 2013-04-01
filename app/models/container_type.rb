class ContainerType < ActiveRecord::Base
  PRIVATE           = "private"
  PUBLIC            = "public"
  EVENT             = "event"
  TEMPORARY_FAILURE = "temporary_failure"
  PERMANENT_FAILURE = "permanent_failure"

  NAMES = { PRIVATE => "Privado",
            PUBLIC  => "Público",
            EVENT   => "Evento",
            TEMPORARY_FAILURE => "Falha temporária",
            PERMANENT_FAILURE => "Falha permanente" }

  has_many :containers
end
