class AuthRoleSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :description, :permissions, :contexts, :is_deprecated

  def permissions
    object.permissions.collect{ |c| {id: c} }
  end
end
