class LocationReleaseValidator < ActiveModel::Validator
  def validate(record)
    if record.location.team_id_changed?
      unless record.location.team_id_was === options[:team_id]
        record.errors.add(:base, I18n.t("errors.messages.location_release", team: record.location.reload.team.name))
      end
    end
  end
end