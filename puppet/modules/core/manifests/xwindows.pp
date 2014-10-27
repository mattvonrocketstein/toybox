# puppet/modules/core/manifests/xwindows.pp
class core::xwindows{
  $xwindows_xwin_base=['xinit']
  $xwindows_wm_utils = ['xmonad', 'gmrun', 'stalonetray']
  $xwindows_dev_tools = ['emacs23']
  $xwindows_misc = ['chromium-browser']
  package { $xwindows_xwin_base: ensure => installed}
  package { $xwindows_wm_utils: ensure => installed}
  package { $xwindows_dev_tools: ensure => installed}
  package { $xwindows_misc: ensure => installed}
}
