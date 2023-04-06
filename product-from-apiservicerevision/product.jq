{
    "group": "catalog",
    "apiVersion": "v1alpha1",
    "kind": "Product",
    "title": "\(.[0][0].name) Product",
    "name": "\(.[0][0].name)-product",
    "spec" : {
        "assets": [
            {
                "name": "\(.[1][0].name)"
            }
        ],
        "description": "\(.[0][0].title) Product"
    }
}