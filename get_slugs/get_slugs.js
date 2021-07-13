const { Client, LogLevel } = require('@notionhq/client');
var fs = require('fs');
const config = require('config');
var slugify = require('slugify');

const NOTION_API = config.get('NOTION_API');
const DATABASE_IDS = config.get('DATABASE_IDS');
const SLUGS_JSON = config.get('SLUGS_JSON');

const notion = new Client({ 
  auth: NOTION_API,
  logLevel: LogLevel.DEBUG
});

(async () => {
  var json = {};
  json.page_slug = [];
  for (var [ dbName, dbId ] of Object.entries(DATABASE_IDS)) {
    console.info(dbName, dbId);
    const response = await notion.databases.query({
      database_id: dbId
    });
    for (var item in response.results) {
      let slug = {};
      slug.page = response.results[item].id.split('-').join('');
      slug.slug = dbName + "/";
      slug.perma_link = slug.slug;
      if (response.results[item].properties.Name.title.length > 0) {
        slug.slug += slugify(response.results[item].properties.Name.title[0].plain_text, {
          remove: undefined,
          strict: true,
          lower: true,
          locale: 'es'
        })
        slug.perma_link += response.results[item].properties['#'].number
        json.page_slug.push(slug);
      }
    }
  }
  if (json.page_slug.length === 0) {
    console.error('[ERROR] table content empyt, file not written.');
    proxecc.exit(2);
  }
  fs.writeFile(SLUGS_JSON, JSON.stringify(json), (e) => {
    if (e) {
      console.error('[ERROR] ' + e);
      process.exit(1);
    }
  })
})();