# Copyright (C) 2018 Xianguang Zhou <xianguang.zhou@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

project('drive-remover', 'c', 'vala')

src_list = ['app.vala', 'menu.vala']

gtk_dep = dependency('gtk+-2.0')
notify_dep = dependency('libnotify')

dep_list = [gtk_dep, notify_dep]

executable('drive-remover', sources: src_list, dependencies: dep_list)

