"""
Applet: Ethereum Grafitti
Summary: Ethereum block grafittisk
Description: Shows the Grafitti of the latest Ethereum block.
Author: 0xmetaclass
"""

load("render.star", "render")
load("encoding/json.star", "json")
load("schema.star", "schema")
load("cache.star", "cache")
load("http.star", "http")
load("humanize.star", "humanize")

def main(config):
    [grafitti, slot] = get_graffiti()
    
    return render.Root( 
        render.Padding(
            child = render.Column(
                children = [
                    render.Text(humanize.comma(slot), font = "tom-thumb", color = '#ffffff99'),
                    render.WrappedText(grafitti),                
                ]                
            ),
            pad = 1
        )               
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [            
        ],
    )


def get_graffiti():
    key = "latest"    
    cached = cache.get(key)

    if cached != None:
        print("use cached data")
        block = json.decode(cached)

    else:    
        print("call beaconchain api")
        rep = http.get(
            "https://beaconcha.in/api/v1/slot/{slot}".format(slot = "latest"),        
        )
        if rep.status_code != 200:
            fail("beaconchain request failed with status %d", rep.status_code)

        block = rep.json()["data"]
        cache.set(key, json.encode(block), ttl_seconds = 12)

    return [block["graffiti_text"], block['slot']]