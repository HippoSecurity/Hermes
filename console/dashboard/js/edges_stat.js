var edges_stat = new Object();

edges_stat.current_mid = null;

edges_stat.current_nodeid = 1;

edges_stat.refresh = function () {
    // body...
    var url = "./edges";
    $.ajax({
        type: "GET",
        url: url,
        // data_Type: "json",

        success: function (json_data) {
            var servers = $.parseJSON(json_data);
            var node = [];
            // {text:"Edge Server", node:[{text:"边缘服务器1"}, {text:"cba"}]}
            // [{text:"abc"}, {text:"bac"}]
            for (var index = 0; index<servers.data.length; index++)
            {
                var data = servers.data[index];
                
                if (servers.data[index].name)
                {
                    node.push({
                        text:data.name,
                        mid: data.mid
                    })
                }
                else
                {
                    node.push({
                        text:data.ip,
                        mid: data.mid
                    })                   
                }
            }

            var treeData = [
                {
                    text: "Edge Server",
                    nodes: node
            }]
  
            $('#edges_tree').treeview({data:treeData});

            $('#edges_tree').on('nodeSelected', function(e, data) {
                // console.log(data);
                edges_stat.current_nodeid = data.nodeId;
                edges_stat.current_mid = data.mid;
                monitor.set_mid(data.mid);
            })

            $('#edges_tree').on('nodeUnselected', function(e, data) {
                // console.log(data);
                if (edges_stat.current_nodeid == data.nodeId) 
                {
                    aler("123");
                    $('#edges_tree').treeview('selectNode', [ edges_stat.current_nodeid, { silent: true } ]);
                }
                
            })

            $('#edges_tree').treeview('selectNode', [ edges_stat.current_nodeid, { silent: true } ]);

            console.log($('#edges_tree'));
        }
        
    })
}


edges_stat.start = function () {
    var refresh_interval = 3;

    edges_stat.refresh_timer = window.setInterval( edges_stat.refresh, refresh_interval * 1000 );
    edges_stat.refresh();
}

edges_stat.stop = function () {
    if (edges_stat.refresh_timer != null) {
        window.clearInterval(edges_stat.refresh_timer);
        edges_stat.refresh_timer = null;
    }
}




