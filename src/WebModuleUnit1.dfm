object WebModule1: TWebModule1
  Actions = <
    item
      Default = True
      MethodType = mtGet
      Name = 'Root'
      PathInfo = '/'
      OnAction = WebModule1RootAction
    end
    item
      MethodType = mtGet
      Name = 'Images'
      PathInfo = '/img*'
      OnAction = WebModule1ImagesAction
    end
    item
      MethodType = mtGet
      Name = 'Buttons'
      PathInfo = '/btn*'
      OnAction = WebModule1ButtonsAction
    end>
  Height = 230
  Width = 415
end
