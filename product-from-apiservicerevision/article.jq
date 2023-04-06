{
    group: "catalog",
    apiVersion: "v1",
    kind: "Resource",
    title: env.docTitle,
    metadata: {
        scope: {
            kind: "Product",
            name: .[0].name,
        }
    },
    spec: {
        data: {
          type: "text",
          content: env.docContent
        },
        fileType: "markdown",
        contentType: "text/markdown"
    }
}