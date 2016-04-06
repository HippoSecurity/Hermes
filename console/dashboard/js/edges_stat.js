var edges_stat = new Object();

edges_stat.refresh = function () {
    // body...
    var url = "./edges";
    $.ajax({
        type: "GET",
        url: url,
        // data_Type: "json",

        success: function (json_data) {
            var servers = $.parseJSON(json_data);
            console.log(servers);
            var node = []

            // [{text:"abc"}, {text:"bac"}]
            for (var index = 0; index<servers.data.length; index++)
            {
                if (servers.data[index].name)
                {
                    node.splice(0, 0, {text:servers.data[index].name})
                }
                else
                {
                    node.splice(0, 0, {text:servers.data[index].ip})
                }
            }

            var treeData = [
                {
                    text: "Edge Server",
                    nodes: node
            }]
  
            $('#edges_tree').treeview({data:treeData});
        }
        
    })
}
