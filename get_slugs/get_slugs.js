const { Client, LogLevel } = require('@notionhq/client');
const fs = require('fs');
const config = require('config');
const slugify = require('slugify');

const NOTION_API = config.get('NOTION_API');
const DATABASE_IDS = config.get('DATABASE_IDS');
const SLUGS_JSON = config.get('SLUGS_JSON');

const notion = new Client({
  auth: NOTION_API,
  logLevel: LogLevel.DEBUG
});

(async () => {
  try {
    let json = { page_slug: [] };

    for (const [dbName, dbId] of Object.entries(DATABASE_IDS)) {
      console.info(dbName, dbId);
      const response = await notion.databases.query({
        database_id: dbId
      });

      for (const item of response.results) {
        let slug = {
          page: item.id.replace(/-/g, ''),
          slug: `${dbName}/`,
          perma_link: `${dbName}/`
        };

        if (item.properties.Name.title.length > 0) {
          slug.slug += slugify(item.properties.Name.title[0].plain_text, {
            remove: undefined,
            strict: true,
            lower: true,
            locale: 'es'
          });
          console.debug(item.properties);

          if ('#' in item.properties) {
            console.info('#', item.properties['#'].number);
            slug.perma_link += item.properties['#'].number;
            json.page_slug.push(slug);
          }
        }
      }
    }

    if (json.page_slug.length === 0) {
      console.error('[ERROR] table content empty, file not written.');
      process.exit(2);
    }

    fs.writeFile(SLUGS_JSON, JSON.stringify(json), (e) => {
      if (e) {
        console.error(`[ERROR] ${e}`);
        process.exit(1);
      }
    });
  } catch (error) {
    console.error(`[ERROR] An exception occurred: ${error}`);
    process.exit(1);
  }
})();