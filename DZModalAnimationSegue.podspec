Pod::Spec.new do |s|
  s.name     = 'DZModalAnimationSegue'
  s.license  = 'MIT'
  s.summary  = 'A custom UIStoryboardSegue subclass that gives special transitions to modal view controllers.'
  s.homepage = 'https://github.com/zwaldowski/DZModalAnimationSegue'
  s.author   = { 'Zachary Waldowski' => 'zwaldowski@gmail.com' }
  s.source   = { :git => 'https://zwaldowski@github.com/zwaldowski/DZModalAnimationSegue.git' }
  s.source_files = '*.{h,m}'
  s.resources    = 'Resources/*.png'
  s.clean_paths  = 'DZModalAnimationDemo/', 'DZModalAnimationDemo.xcodeproj/', '.gitignore'
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
