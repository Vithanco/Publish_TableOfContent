# Publish_TableOfContent
Table of Content plugin for Publish static website generator

Includes as well a breadcrumb generator. 

Currently this package uses https://github.com/vithanco/Publish as https://github.com/sundell/Publish is currently stale.
It will switch back as soon as possible. 

 
I use this not really as a plugin, but as as HTML Component. 

First, ensure protocol compliance
```
// This type acts as the configuration for your website.
struct YourWebSite: Publish.Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
    }
    
    struct ItemMetadata: HasShortTitle {  //add protocol compliance 
        var shortTitle: String?   // add this optional metadata, use it when your index/section/item title is too long
    }'
```

This will allow your website to create a TOC! Use it similar to this:

```
func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
    return  HTML(
    // as always, normally .head(...)
        .body(
            .components {
                SiteHeader(context: context, selectedSelectionID: item.sectionID)
                ItemWrapper{
                    Article {
                        Breadcrumps(section: context.sections[item.sectionID],item: item)   //relevant
                        H1(item.content.title)
                        Div(item.content.body).class("content")
                    }
                    Aside{
                        TableOfContent(items: context.sections[item.sectionID].items, item: item) ///relevant
                        ItemTagList(heading: "Tagged with:", item: item, site: context.site)
                    }.class("side-content")
                }
                SiteFooter()
            }
        )
    )
}
```



