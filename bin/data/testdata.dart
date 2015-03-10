Map ReceptionEvent_1_4 =
{
        "id": 4,
        "start": 1395817200,
        "stop": 1396022400,
        "content": "Mus samtaler"
};


Map NewReceptionEvent_1 =
{
        "start": 1395917200,
        "stop": 1396122400,
        "content": "Ged samtaler"
};

Map testContact_1_2 =
{
    "reception_id": 2,
    "contact_id": 1,
    "wants_messages": true,
    "enabled": true,
    "full_name": "Thomas Løcke",
    "distribution_list": {
        "to": [
            {
                "reception" :
                    { "id" : 2,
                      "name" : "Test"
                    },
                 "contact" : {
                   "id" : 1,
                   "name" : "Other guy"
                 }
            }
        ],
        "cc": [],
        "bcc": []
    },
    "contact_type": "human",
    "phones": [],
    "endpoints": [
        {
            "address": "+4588329100",
            "address_type": "sms",
            "confidential": false,
            "enabled": false,
            "priority": 0,
            "description": null
        }
    ],
    "backup": ["Steen Løcke"],
    "emailaddresses": ["tl@ff.dk"],
    "handling": ["spørg ikke ind til ekstra stærk varianten"],
    "workhours": [],
    "tags": [
        "Fisker",
        "sømand",
        "pirat"
    ],
    "department": "Fangst",
    "info": "Tidligere fisker I militæret; sværdfisker.",
    "position": "Key fishing manager",
    "relations": "Gift med Trine Løcke",
    "responsibility": "Fersk fisk, Trolling"
};

Map testMessage_1_Map =
{
    "id": 1,
    "message": "About Car rental; are there convertibles in stock?",
    "context": {
        "contact": {
            "id": 4,
            "name": "Kim Rostgaard"
        },
        "reception": {
            "id": 1,
            "name": "BitStackers"
        }
    },
    "taken_by_agent": {
        "name": "Kim Rostgaard Christensen",
        "id": 2,
        "address": "krc@bitstack.dk"
    },
    "caller": {
        "name": "John Johnson",
        "company": "AnyCorp",
        "phone": "22114411",
        "cellphone": "33551122",
        "localExtension": ""
    },
    "flags": [
        "urgent"
    ],
    "sent": true,
    "enqueued": false,
    "created_at": 1424540061,
    "recipients": {
        "to": [
            {
                "contact": {
                    "id": 4,
                    "name": "Kim Rostgaard Chrisensen"
                },
                "reception": {
                    "id": 1,
                    "name": "BitStackers"
                }
            }
        ],
        "cc": [
            {
                "contact": {
                    "id": 4,
                    "name": "Kim Rostgaard Chrisensen"
                },
                "reception": {
                    "id": 2,
                    "name": "Gir"
                }
            }
        ],
        "bcc": []
    }
};

Map reception_1 = {
    "id": 1,
    "full_name": "BitStackers",
    "enabled": true,
    "extradatauri": "https://docs.google.com/document/d/1JLPouzhT5hsWhnnGRDr8UhUQEZ6WvRbRkthR4NRrp9w/pub?embedded=true",
    "reception_telephonenumber": "12340001",
    "last_check": "2015-01-26 15:37:40.000",
    "attributes": {
        "short_greeting": "Du taler med...",
        "addresses": [
            "For enden af regnbuen",
            "Lovelace street",
            "Farum Gydevej",
            "Hvor kongerne hænger ud"
        ],
        "alternatenames": [
            "Code monkeys",
            "Software Developers",
            "Awesome dudes",
            "Bug Hunters",
            "SuperHeroes"
        ],
        "bankinginformation": [
            "Bank banken 123456789",
            "Trojanske bank 123456789",
            "Ostdea 123456789",
            "Tyste Bank 123456789",
            "Bank Bank Bank 123456789"
        ],
        "salescalls": [
            "Stil dem videre til Thomas",
            "Spørg om hvor mange liter mælk der i køleskabet tættest på dem lige nu",
            "Sig at det lyder spændende, og de kan sende en email til gtfo@bitstack.dk",
            "Bed dem om at ringe igen, ved næste fuldmåne",
            "Begynd at snakke om din hund, og hvor godt du har oplært den osv."
        ],
        "customertype": "Kundetypen. Det afhænger med at situationen. Nogle gange skal der sælges katte, andre gange er det måske computer programmer, og andre dage kan det være faldskærmsudspring.",
        "emailaddresses": [
            "mail@bitstack.dk",
            "support@bitstack.dk",
            "finance@bitstack.dk",
            "research@bitstack.dk",
            "production@bitstack.dk",
            "denmark-department@bitstack.dk"
        ],
        "greeting": "Velkommen til BitStackers, hvad kan jeg hjælpe med?",
        "handlings": [
            "Lad tlf. ringe 4-5 gange.",
            "Indgang til deres kontor ligger i gården.",
            "Kunder skal tiltales formelt, med både fornavn og efternavn.",
            "Biler bedes parkeres hos naboen",
            "Spørg efter ordrenummer",
            "De skal være over 18 år, før at der må handles med dem",
            "Geden i forhaven er der for at holde græsset nede"
        ],
        "openinghours": [
            "Mandag 08:00:00 - 17:10:00",
            "Tirsdag 08:00:00 - 17:05:00",
            "Onsdag 08:00:00 - 17:02:00",
            "Torsdag 08:00:00 - 17:08:00",
            "Fredag 08:00:00 - 16:30:00",
            "Lørdag 08:00:00 - 18:00:00",
            "Resten af ugen fri"
        ],
        "other": "Bonus info: Man ville skulle bruge 40.5 milliarder LEGO klodser for at bygge et tårn til månen. Ludo opstod i 1896, da det blev patenteret i England som patent nr.En undersøgelse fra slutningen af 2008 viser vi bruger op mod 30% af vores fritid på online aktiviteter. Mandens hjerne rumfang er på ca. 1300 ml.",
        "product": "Software produkter, men ikke bare hvilket som helst software produkter. Det er af den højeste kvalitet menneskeheden kan fremskaffe. Deres produkter er blevet brugt til at undgå 4 komet sammenstød med jorden, som ellers ville havde ændret verden som vi kender den",
        "registrationnumbers": [
            "DK-123456789",
            "SE-2835629523",
            "DE-385973572",
            "UK-1035798361",
            "PL-9792559265"
        ],
        "telephonenumbers": [
            "+45 10 20 30 40",
            "+45 20 40 60 80"
        ],
        "websites": [
            "http://bitstackers.dk",
            "http://bitstack.dk",
            "http://bitstack.me",
            "http://bitstackers.org",
            "http://bitstackers.stuff",
            "http://bitstack.software",
            "http://bitstack.welldone"
        ]
    }
};