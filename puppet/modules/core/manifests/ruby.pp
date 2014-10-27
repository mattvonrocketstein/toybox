# puppet/modules/core/manifests/ruby.pp
class core::ruby{
    $packageList = [
        'ruby',
        'rubygems'
    ]

    package{ $packageList: }
}
