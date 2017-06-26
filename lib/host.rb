module Puppetstein
  class Host
    attr_accessor :string # platform
    attr_accessor :family_string
    attr_accessor :family
    attr_accessor :flavor
    attr_accessor :beaker_flavor
    attr_accessor :beaker_version
    attr_accessor :version
    attr_accessor :arch
    attr_accessor :vanagon_arch
    attr_accessor :vanagon_string
    attr_accessor :hostname

    def initialize(platform)
      @string         = platform
      @family         = get_platform_family(@string)
      @flavor         = get_platform_flavor(@string)
      @version        = get_platform_version(@string)
      @arch           = get_platform_arch(@string)
      @vanagon_arch   = get_vanagon_arch(@string)
      @vanagon_string = get_vanagon_string(@string)
      @family_string  = "#{@family}-#{@version}-#{@arch}"
      @beaker_flavor  = get_platform_beaker_hostgen_flavor(@string)
      @beaker_version = get_platform_beaker_hostgen_version(@string)
    end

    def get_platform_family(platform_string)
      p = platform_string.split('-')
      case p[0]
      when 'centos', 'redhat'
        'el'
      when 'debian', 'ubuntu'
        'debian'
      when 'win'
        'win'
      when 'osx'
        'osx'
      end
    end

    def get_platform_flavor(platform_string)
      base = platform_string.split('-')[0]
      version = get_platform_version(platform_string)
      case base
        when 'redhat', 'centos'
          base
        when 'win'
          'windows'
        when 'osx'
          'osx'
        when 'debian', 'ubuntu'
          case version
            when '7'
              'wheezy'
            when '8'
              'jessie'
            when '9'
              'stretch'
            when '1204'
              'precise'
            when '1404'
              'trusty'
            when '1504'
              'vivid'
            when '1510'
              'wily'
            when '1604'
              'xenial'
          end
      end
    end

    # Annoyingly, this is different than regular flavor for ubuntu/debian
    def get_platform_beaker_hostgen_flavor(platform_string)
      base = platform_string.split('-')[0]
      case base
        when 'redhat', 'centos', 'debian', 'ubuntu'
          base
        when 'win'
          'windows'
        when 'osx'
          'osx'
      end
    end

    def get_platform_beaker_hostgen_version(platform_string)
      os = platform_string.split('-')[0]
      base = platform_string.split('-')[1]
      case os
        when 'osx'
          "#{@version[0, 2]}#{@version[2..-1]}"
        else
          base
        end
    end

    def get_platform_version(platform_string)
      platform_string.split('-')[1]
    end

    def get_platform_arch(platform_string)
      platform_string.split('-')[2]
    end

    # When building puppet-agent, debian based beaker_platform_strings use 'amd' instead of 'x86',
    # and Windows uses 'x64' and 'x86'.
    def get_vanagon_arch(platform_string)
      pooler_arch = platform_string.split('-')[2]
      case platform_string.split('-')[0]
      when 'debian', 'ubuntu'
        pooler_arch == 'x86_64' ? 'amd64' : pooler_arch
      when 'win'
        pooler_arch == 'x86_64' ? 'x64' : 'x86'
      else
        pooler_arch
      end
    end

    def get_vanagon_string(platform_string)
      case platform_string.split('-')[0]
      when 'osx'
        puts "osx-#{@version[0, 2]}.#{@version[2..-1]}-#{@vanagon_arch}"
        "osx-#{@version[0, 2]}.#{@version[2..-1]}-#{@vanagon_arch}"
      when 'win'
        "windows-#{@version}-#{@vanagon_arch}"
      else
        "#{@family}-#{@version}-#{@vanagon_arch}"
      end
    end
  end
end
