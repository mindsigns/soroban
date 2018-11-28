exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
        //order: {
        //    before: [
        //        "web/static/vendor/js/sb-admin.min.js"
        //    ]
       // }
    },
    stylesheets: {
        joinTo: {"css/app.css": [
            'web/static/css/*',
            'web/static/vendor/css/*'
        ]}
//      order: {
//        before: [
//            "web/static/css/phoenix.css"
//        ],
//        after: [
//            "web/static/css/app.scss"
//        ]
//      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static",
      "scss"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    copycat: {
        // file copied into priv/static/
        "webfonts": ["node_modules/@fortawesome/fontawesome-free/webfonts/"],
        verbose : true
    },
    sass: {
        options: {
            // for sass-brunch to @import files
            includePaths: ["node_modules/bootstrap/scss"], 
            precision: 8 // minimum precision required by bootstrap
        }
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "jquery"], 
        globals: {
            // Bootstrap JavaScript requires both '$', 'jQuery'
            $: 'jquery',
            jQuery: 'jquery',
            bootstrap: 'bootstrap' // require Bootstrap JavaScript globally too
    }
  }
};
