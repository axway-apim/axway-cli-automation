{
    group: "catalog",
    apiVersion: "v1",
    kind: "Document",
    title: "API Document",
    metadata: {
        scope: {
            kind: "Product",
            name: "\(.[0][0].name)",
        }
    },
    spec: {
        sections: [
        {
            title: "Overview",
            articles: [
                 .[1][] | {
                     kind: .kind, 
                     name: .name,
                     title: .title
                }
            ]
        }
        ]
    }
}