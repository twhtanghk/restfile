shim = {
	underscore : {
		path : 'node_modules/underscore/underscore.js',
		exports : '_'
	},
	backbone : {
		path : 'node_modules/backbone/backbone.js',
		exports : 'Backbone',
		depends : {
			underscore : 'underscore'
		}
	},
	'backbone.marionette' : {
		path : 'node_modules/backbone.marionette/lib/backbone.marionette.js',
		exports : 'Marionette',
		depends : {
			jquery : '$',
			backbone : 'Backbone',
			underscore : '_'
		}
	}
};

grunt = require('grunt')

grunt.initConfig({
	browserify : {
		all : {
			src : 'client/index.coffee',
			dest : 'public/js/index.js',
			options : {
				shim : shim,
				transform : [ 'coffeeify', 'debowerify' ]
			},
		}
	},
	uglify : {
		options : {
			// the banner is inserted at the top of the output
			banner : '/*! geo <%= grunt.template.today("dd-mm-yyyy") %> */\n'
		},
		dist : {
			files : {
				'public/js/index.min.js' : [ 'public/js/index.js' ]
			}
		}
	},
	copy : {
		main : {
			src : 'public/js/index.min.js',
			dest : 'public/js/index.js'
		}
	},
	less : {
		compile : {
			options : {
				paths : [ 'bower_components/bootstrap/less' ],
				strictimports: true,
				syncImport: true
			},
			files : {
				'public/css/main.css' : 'views/main.less'
			}
		}
	},
	appcache : {
		options : {
			basePath : 'public'
		},
		all : {
			dest : 'public/cache.manifest',
			cache : 'public/**/*',
			network : '*',
		}
	},
	clean : [ 'public/js/index.js', 'public/js/index.min.js',
			'public/css/main.css', 'public/cache.manifest' ]
});

grunt.loadNpmTasks('grunt-browserify');
grunt.loadNpmTasks('grunt-contrib-uglify');
grunt.loadNpmTasks('grunt-contrib-copy');
grunt.loadNpmTasks('grunt-contrib-less');
grunt.loadNpmTasks('grunt-appcache');
grunt.loadNpmTasks('grunt-contrib-clean');