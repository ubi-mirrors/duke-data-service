module DDS
  module V1
    class FoldersAPI < Grape::API
      desc 'Create a project folder' do
        detail 'Creates a project folder for the given payload.'
        named 'create project folder'
        failure [
          {code: 200, message: 'This will never happen'},
          {code: 201, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Project Does not Exist, Parent Folder does not exist in Project'}
        ]
      end
      params do
        requires :parent, type: Hash do
          requires :kind, desc: "Parent kind", type: String
          requires :id, desc: "Parent ID", type: String
        end
        requires :name, type: String, desc: "Folder Name"
      end
      post '/folders', root: false do
        authenticate!
        folder_params = declared(params, include_missing: false)
        if folder_params[:parent][:kind] == Project.new.kind
          project = hide_logically_deleted Project.find(params[:parent][:id])
        else
          parent = Folder.find(folder_params[:parent][:id])
          project = hide_logically_deleted parent.project
        end
        folder = project.folders.build({
          parent: parent,
          name: folder_params[:name]
        })
        authorize folder, :create?
        if folder.save
          folder
        else
          validation_error!(folder)
        end
      end

      desc 'View folder details' do
        detail 'Returns the folder details for a given uuid of a folder.'
        named 'view folder'
        failure [
          {code: 200, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Folder does not exist'}
        ]
      end
      get '/folders/:id', root: false do
        authenticate!
        folder = hide_logically_deleted Folder.find(params[:id])
        authorize folder, :show?
        folder
      end

      desc 'Delete a folder' do
        detail 'Remove the folder for a given uuid.'
        named 'delete folder'
        failure [
          {code: 200, message: 'This will never happen'},
          {code: 204, message: 'Successfully Deleted'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Folder does not exist'}
        ]
      end
      delete '/folders/:id', root: false do
        authenticate!
        folder = hide_logically_deleted Folder.find(params[:id])
        authorize folder, :destroy?
        folder.move_to_trashbin
        folder.save
        body false
      end

      desc 'Move folder' do
        detail 'Move a folder with a given uuid to a new parent.'
        named 'move folder'
        failure [
          {code: 200, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Folder does not exist, Parent does not exist'}
        ]
      end
      params do
        requires :parent, type: Hash do
          requires :kind, desc: "Parent kind", type: String
          requires :id, desc: "Parent ID", type: String
        end
      end
      put '/folders/:id/move', root: false do
        authenticate!
        folder_params = declared(params, include_missing: false)
        folder = hide_logically_deleted Folder.find(params[:id])
        update_params = {parent: nil}
        if folder_params[:parent][:kind] == Project.new.kind
          update_params[:project] = hide_logically_deleted Project.find(folder_params[:parent][:id])
        else
          update_params[:parent] = hide_logically_deleted Folder.find(folder_params[:parent][:id])
        end
        authorize folder, :move?
        if folder.update(update_params)
          folder
        else
          validation_error!(folder)
        end
      end

      desc 'Rename folder' do
        detail 'Give a folder with a given uuid a new name.'
        named 'rename folder'
        failure [
          {code: 200, message: 'Valid API Token in \'Authorization\' Header'},
          {code: 401, message: 'Missing, Expired, or Invalid API Token in \'Authorization\' Header'},
          {code: 404, message: 'Folder does not exist'}
        ]
      end
      params do
        requires :name
      end
      put '/folders/:id/rename', root: false do
        authenticate!
        folder_params = declared(params, include_missing: false)
        new_name = folder_params[:name]
        folder = hide_logically_deleted Folder.find(params[:id])
        authorize folder, :rename?
        if folder.update(name: new_name)
          folder
        else
          validation_error!(folder)
        end
      end
    end
  end
end
