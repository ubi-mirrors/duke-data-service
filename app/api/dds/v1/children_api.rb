module DDS
  module V1
    class ChildrenAPI < Grape::API
      helpers PaginationParams

      desc 'List folder children' do
        detail 'Returns the immediate children of the folder.'
        named 'list folder children'
        failure [
          {code: 200, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Folder does not exist'}
        ]
      end
      params do
        optional :name_contains, type: String, desc: 'list children whose name contains this string'
        optional :exclude_response_fields, type: Array[String],
          coerce_with: ->(val) { val.split(/\s+/) },
          desc: 'Space delimited list of fields to exclude from the serialized response.'
        use :pagination
      end
      get '/folders/:id/children', adapter: :json, root: 'results' do
        authenticate!
        folder = hide_logically_deleted Folder.find(params[:id])
        authorize folder, :index?
        name_contains = params[:name_contains]
        if name_contains.nil?
          descendants = policy_scope(folder.children)
        else
          descendants = policy_scope(folder.descendants)
          descendants = descendants.where(Container.arel_table[:name].matches("%#{name_contains}%")) unless name_contains.empty?
        end
        paginate(descendants.includes(:parent, :project, :audits).where(is_deleted: false))
      end

      desc 'List project children' do
        detail 'Returns the immediate children of the project.'
        named 'list project children'
        failure [
          {code: 200, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Project does not exist'}
        ]
      end
      params do
        optional :name_contains, type: String, desc: 'list children whose name contains this string'
        optional :exclude_response_fields, type: Array[String],
          coerce_with: ->(val) { val.split(/\s+/) },
          desc: 'Space delimited list of fields to exclude from the serialized response.'
        use :pagination
      end
      get '/projects/:id/children', adapter: :json, root: 'results' do
        authenticate!
        name_contains = params[:name_contains]
        project = hide_logically_deleted Project.find(params[:id])
        authorize DataFile.new(project: project), :index?
        if name_contains.nil?
          descendants = project.children
        else
          descendants = project.containers
          descendants = descendants.where(Container.arel_table[:name].matches("%#{name_contains}%")) unless name_contains.empty?
        end
        paginate(policy_scope(descendants.includes(:parent, :project, :audits)).where(is_deleted: false))
      end
    end
  end
end
