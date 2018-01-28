project('drive-remover', 'c', 'vala')

src_list = ['app.vala', 'menu.vala']

gtk_dep = dependency('gtk+-2.0')
notify_dep = dependency('libnotify')

dep_list = [gtk_dep, notify_dep]

executable('drive-remover', sources: src_list, dependencies: dep_list)

