#include "resultscreater.h"

const QString ResultsCreater::LAA_LOG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAASwAAAA+CAYAAACRFCZRAAAACXBIWXMAAAk6AAAJOgHwZJJKAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAGRhJREFUeJztnXl4XNV1wH/nvZFkSTOybGNsiAnY1njDQBKTFGyNRoqdAkmAAIGSNCGEJS1pQ4AulNAGUhKy9Gsa2rRQCBCzhRBCgEIMSYysxZC0dhKwsbEl2xjbYIOxZY0WS5p3T/+YkTzSvJk30kjWwvt93/yhu5x75unp6N5zzz1XVBUfn3wIzav6S1TuTClqA3rSGgpXxbbWPXFUlfOZUARGWwGf8Y+odZXS7x9f0K2dKpcDvsHyGTLiz7B88iE4p+pUseXlHJvH1SmY1bb9N/tGWC2fCYo12gr4jG/Eli8NonmAQM+lI6iOzwRHtIEpo63EmCBOJ9V6eLTVGE/I7JpJwYB5E3J/hwRZ39q05vSR1cxnQvE7KaMHG0C0jnsRrhhtnXyOKi3AfmAPystY/BbhGZZpbDBCguGqzwny4GAHV8OpbdvqNgy235BZLyV0UuRaF8cmQFnGvkoQoSBDbQAIZRk5lNFPbCjEojTLuJORDCsgpQilJMu4mf+BCMXApIy1UJ5FbilQmEEnG8nyHBN+zUzPsSCT33PAGPeJ/pYyuvk/YJ5nB5+JTAfCPRzmFlbooVw6hMJVtSDVgx1IVb/X1lx/46A6bZJC9rMC4QyUDwAnIMwEinL4Q/MZ/2yjkA8lnO6NMgfDiwgzRlsrn1FnMxAlou9ka1Q+PzLHMVZz0lgMljfbmme8X/Uxx7PlKimilL9DuA6YNoSxfMY/B3CIUq0bE1POSt2O8KcIr422Zj6jzkLgDq9GcWNdPURjBXB8acW+5Z6t1kqIUtYg3OYbq/csm4EaqnUj/XYJI/oKNh8Cvp8M/PN573IJayTjEktqagICl+UzgIV83rORw3cQzshnHJ9xSwzhXwmwhIi+0lvoHoe1RoLYfBpYDsxJ+gmGm8l+WMUYxuI8lumrblVl4arzFXkyzxE6JtnOzHdea3R39K+SIoK0ZHEQ+4wtejwmOq2AuwtA6EZpB7qA7Si/wfBzqjVNnvsORqLhj5MfH59+GOTKHNaC+4FjstSXdBnroozv2GRm4dAJdCZLDgEmg6wuoCPLWC1ApgjpwyljpKMczFhn0YnBPRTGQpPjZpLbgdCVoc4gZN74MLRj0e1a5+Bg05qxr9CGuhybStTFUTLvFMeJUa3xjPVHAT/S3WdQBGfXzJSA2eVxrKtHVC9RkV94iHsh1lTn7cvy8UniL8l8BoXY5krvM6jyVGtz/ZOobPEQV1O+IDp7OPXzmdj4BssnZ0REEC73aqeYHyU68IiXSCfOZ4dLP5+JTx7ZGkSo58ZxEbAnWCiTR1uNo8hhqrgeNM3nU35iZAqTsh+lMQRaW7fU7h9YHpwbrQatyNZX0J1tzQ2/BrAt5yHHWLdmC39QONOtvGT+8veJ0z1TbOIBXPwqYql0WQcP7qh18ROJRSPfx1CcTdcJgXAIzejbG4u0UMV3YWi+qDwMliqW7EH59tBlHEWGGjE0PnnIzVgBmEJ5RI2cna2ziPNFV2e46FVeA6twr2pi7JYtDdtD4ehLwNJM7S1LH3crt038p4i1DJNpawkIGC2fH6lo2dKwfYAWBpWpCN6hExOB8fVuf36oxoq8l4SV+iDKA3nJ8Bl+lHvcikvCNbMU+ZhH77ZJhXaaEZkyu6YcuMCjr3EcXdm/SB7K0r61pLj4ZwMLy+ZG5mUzcqnCHWN/zrXG4u4c+vscTYT/JKLZ3gdP8vdhtfMl4Nm85fgMD8JrVNHgVmVjroTEqfeMKA+/vbE2Lf4lXqCXQfYlliqrOrY1vJFaZhV1/zQZduA21iN7X36+fWCxEfuqXOcNil4uIultl2kjsCkXGT5HAeEJ3uKr+YrJ32Cdo11EOBfluowvps/R5B63KXfyj9ozOt2o3OtaofpFr76WaNrM7tDGFw8Az7mPZaWNlYiiV/dZkwsCs4MVkaoM1a4zTZ+jSg/KN3iLS7hYvc+OejBMu4SqVOkdWJyGcEcyaNDn6NNFFyvdKkorqj6WPLWQjQ3t29b8X1rfudUfBj7g0XdvbHLHL92rXJYBwivt22rXDSwO7XY+gXCcx1j9pcMXXCsCPJAMDPU5+uxHuAOHU6nSW4fDWDHsOd2X6RbgOtbI32JxChYnjcu88QYHK0u08GijhIH/SisXfs5yfdeti8CVnnJFfuRWbIl69lXkfl23zjWCui1uPxMMmJZ+O8omfTZG7lH0A5BLjl1cc23aUvZMPUCDPA64zdiuQWge9FAjgVKEZM1vNT5I5OnqQHidEjawRN0j6vNgZIxJInz/D8mPz3DTKGe7HjRRd0dz2cIV04DzPaR2i0ha3JScsLQ4OKngzzz6qq1yX8bKHbWHQ+Hqx6Fvl/Gw3aMPD2yXiKIn6w6mGwKlHYfNReAyu1TuQVwN1mwq9a7BjuUzuviBo+ONVVKEuvqithCh3q2LiXdf5nmAXfXnbrFXoeLCSz1j7YQXDjXXesxWzENHmsvjLTsb0s7oWQFzeZaslNlVEHUPaK3S+gzO9ytYI/7B6nGGb7DGG0EuBqanlau7s52Ew907Ol1xdbarei8HMeq6lEylrbmhXpXXSY2EHzhWJl9UTki0PLx8rnuV63c7hoBnmIbPGOPo+5c2SSEHOCVrG6EAzZLj2bCFKt01oJNFAzVIjmF02XJmj1RfpRDJksf7SLt3ibgZARHgOpceXRh3Z/vkcM0ZwKnZh2NH+/aG2oHlZQsq54PtFQ/1bptje6aaUVUNhqt/AuaStuaGtJlgaF60CljgJScL4hD/PHBrWk0XKynkW2mpapTrQB51NfQNchWSQ9JApR3JkDkhe7/sGRmGq6+iRKhNCyReI7MIZHneDu3YHt9rKhtYpIP/7nlw9A3WIu2mXm5BODdjG684WIuNrJLTOUdTwijUgHwK5a9z1iWfRBVD7ZtLP+FvXMvruQBhiUvNL6hW151Zg/cMSYT7eqPT+3f2jocS5AHdUZvTTpyIPihYLeqSIkSUK/PNG6LKF0Tkn9O+y3J9l0Z5Ak07t/gR6jmXKp5OF0Y58J3cBh6qwkPsN7i+PwRd3a9klRQRYhXK4oy9LM8xnmGRZv4bHiFGZ0nYw9XAW0PurywmyDfTyku4EWFjntqNNi8S59/TSldJEeLynQGE/3YrPnZxTRDUy2HuOGqlHcORxYsL1d1X1g8l7h635UJsa93mkuKi/xxYPi18RpnCp730BN2WrYEIJwUrqt1jsoz7M0L4Jpsk/SYYww9Qfuuh01hnAyWkX/YR5JtZjZU3b9CN5zGtkWB0DNZy3YfFhbgdas2dG6iX/i/nEu3A4lPA7rx1HB02082FrknSgtySzLc+kLVU6ho3YYe7zJ95XEOFKs91NNWmPa9g19TzgGM99H0x1tTompU0E26R7d1S9BnIvq2vyCqFNGOX1k7V3Q9WpfWI6wmAU9jP19JKqzWO4QLAK0XOWGUXyvks0f6JDRskCtyQh9yDwDks11G5vXv0nO7L9LfYVOVxfMJCeJQG6R9kuFS3oSxFSPPJjHGeJUCl64vQKOcCf+/ay/BPmQRqDrFXFu6R7bnEbUmGuK3BkstYlpp7RZ2Hk6l4swjTi6cvqHQ30g63ZFDgZtbKOWnl1boXh0qUVV76jTFeQFlGle7oV7pWjgd+ksff/SZsPkpER+3I0+juEi7VP+KwBOVbwNtDkHAcwguskf4pT6p0F5WsAL6cvHVjrKJAPcr5RPSTnKkH0lrUy1KUn7ieAVRWEVVXw1w2v2YBGVK3pLAvVt72zMDCHA9JxyYVStrB5cESqqhZrMqHPZrti5V3PBtrXvs2kCGaPoFAaZcJuC8vo1qbwfgEMPyUBvlIWk217qdKPw5ckJyhjeUUvZuBa4iwIm1Tql7CKKthcKcIkryN8i0clrBU/zhs2g6B0Y9CT1wP/4+sl2/QydkolcAJaboJrZh+mUbiQAwFbC6jUX5Opb58pFoNEe4E7qRR/gTlwwgnocxAs+b/7s9g8g1JljzdqRhaEHbTzbqsU+t6+TjCzzIslw5SwNWZx3Cu9jo/rKor3aLT8zkkPXiMd8qaFD1FZaWKZg2CTS4L73etLOBq4mxwuR05BKymQT5NRJ9P6xfRJ4EnWSMzsVmCMgsrh1xw3rc0H2GweduEEoR9JMJF/peI/q9ru0Y5DeEiDE8BT6XdSG1ho2m3NseBXQiNFPPcSEStDwU/p/tYZJMU8i63AX+bZRb8GSL6qFuFLF5cGOyatts1XqtfQxbFttb1m4GKiBWqiGxX5MRsXY2a09ubG9Z7f5ksww9BTzn99ILgodI9Hn3UJhBuaVrt7qRvkEuTSyM3HOC7lHDrWPkj9TnC6M+wfFIQoYELgW8D4SwNb89krDjiMPcwAtoY21qftlwuWRiZYXoko2wSfq/WfI1VQs9pnxqsnrpuXU+oIvoIkjVViTj0XAYZfFYRfZQGORW4yaXWBr5GJxfSIDcR4al8Es75DC++wRoLNMgilPMQrgSypiAG7iHCP2ZvIt7LLOPuMG/fVP8W8A9e/YcJb8c+6VHqRlhpkT23ksAXROQbrvFlABFupoHpkGF7XlkA/IIGtoLci8PTVKt/M/ooM3GXhC/KB+hhOnYWP4OhEItSHHYQ1V+n1dfLKVhZHNeKjaSt/TO1nYwml3eJaPypwPuBUwbhCP0P9nJ9tlQdJeGaWTbmdQ8fVGtpyaTj3UIMjhY56tlWXGQd5+YrC4Wr/wh6WtZBVD4aa16Tebf4Z2Izkx9AzsHGbwKvoLyR3N5PYBFL+ny88G5neIkq3ZBWXicfw2Z21jsJARxaKOCd0XaOjxQTd4ZlOAaL59EsnmdJ7vlYdNMoH+nvtAe6eYMink1uArgzGHs/9NzbDnA9Ef0Pr4Z2wont5TB3zfR5NMnJsS88ksmxr5iVgnw/a/fEgejMBith+L9Co2xA+WEOB6+PB45P+z0O3//8NylwOba2Vk7G4mmUSX3vbCYsFOUTwIQ0WBP38HOl/ga4I8fWhcBDvCT9UwCv0EMY/hyGcFZs+HgZWJqLsRIRS8iQtSAFt0yfR5Ncs59aohn1zCUmy8BFGWOyUqnUu4FK4BXPtiNHN8pn0kJbXpJilEfTzkFmQvkey3S8xY3lzMRdEgKslwI6eAL4ZE7tlbup0r9IK2+Uz6Pc7zkjGF4OAN/F4fu5Xg8eDFedJYhrOuIUttuW8YqxyogWOC3JtMdDJji/ZoUYk74E78/GWFNd1kPyoXD0KeC8bG0ErmxtqsuYq6sf66WATm5AudEl7GEkcYDLXS9oaJB7MvrZ0nmYSH630ox1Ju4MC2CJ9jCNi5K7bt4pWoUv0SDpkeOV+iDC2cA7I6RpKq8D1+NwIhH9Xq7GioRrzDsVDMxxjLVtyJ/DRenBlYNETA6xV2SeXR0R5J6hor+cQaSsWaI9VOp3cXg/cH3ydzHSvA2c5WqsGuWWHI2VA9xOCV+cyMaKCT/DSqVeliLcBJzt6btTHqCA612m51OJ81XgryCH1CO50QG8ivA8Dk8TZd1QXrqyhSumabxnj2eivvxobmuun59x5y0HJi9eOtV0FezxWOJ0g86KNdVn/QeRYxxX9pisrIiwliUo56OcBZzsdeZxELyL8kMK+Pe092y1TKOQf0vc4ZeVOPAchtuJ6kvDpNeY5r1jsHppkOMQzkYJo0mjY6EYBt4g3ILFqjRHPMndpeP5IA5/gjUgb9fA/Ehu+eGFNhy6gB1UsTPTpaeDIRiuvkHQf81XTjZUuK5ta12ufkFXQvOqr0XVS8ZjsaY6rywTCXkV0TsQrs3aSOW2WPOarw9GT3dEqOckNHlXQfoOdLCf495QkPZ+GNoQXmIvL6fv9orwIqcR5+y0LK8W5Ziku194F6EJ5TkiOvSsJ+OQ957BmqCEwtUbQU8ewSHaCkzhrAPbfj20pHNJQuHoH7xu4FE4q62p7le5yCsNV33IQryCWHe3Nc84SfWxYbm5xWf0mNg+rPcIZeHqM0fYWAE8kK+xKp1bc3oO14Xtam+esdqjTR/tTfW/B0mfBfdnVumcvdW5yvQZu/gGawKQS1bRfFFD3jfMWJZzRQ7N7h3sTEjhAe+x88kX7zNW8A3WOOfYxTVBgUtGdBBhddu2uvTo68GIOGFpMcilHs1M3AmkZT/1lK09D3nFZCny6alzP5Z7JgSfMcnEjXR/D2HU1IzoAAXyZt4yds/qtt//lvutNkmswCQT2z74ZWesee3boXDlB41mv7YrUBz3fVjjHN/p7uPjM27wl4Q+Pj7jBt9g+fj4jBt8g+Xj4zNu8A2Wj4/PuME3WD4+PuMG32D5+PiMG/w4rDHAtPAZZYd10jLL0mKj+nriuEmC4NzoKSom7Sp1cQJ72nbU7i1bUDnfiUtwYH1HeecrfVdjiUjJ3MoPWWLPUaGlpFBeSs3kGZxTdWqgQNtatjRs7y0rXVB5PHE5rmPbcX8cGHleEq6ZJRqf0fuzMYX7D59o9mhtbRxg+oLKUEdc5g3UyZjC/Z3bV+8sW7himtPTdVJveYEUthwq2rdLN27sBpgyu6a8247PLQno1ndea4ylfgeVwL6OptrdvW16Zdh2oD3W0bVTd73Y2fe95kdOC4jV2vJa3Y6BugRn18xUO/6+1OfU+yzEZp6q3Rboif+uZWfDwYF9fUYPf4Y1ypTNq/5iF0VvWqK/RPmxhawPVUTrp8yuKQcQi2cssdalfQLmcgCN2/e41Ze0TZoOMGVhzUnBiqr1lljrFL1fVFd1dpndpXOjH+/VQWx53jHW7al6WXH7GkusdVMr3igdqLOlem3qWAE7/npwt9lRVhFdCnDYKVjippNtxxMZE5zuc1PLHeLNwa5pu8vmRT4J4NhaY4m17nDcPnLB6pIlAUusdQExX020capTZagxm4OTCvYH50X7LqcQY/3Gcfim23O3AnqFJda60gPlUwFCFcuODYWjdWLLyyAPiJj/iRdau4Lhaq8ULz5HEd9gjSKl4egHVfUeC20Qy5oea6orU7XOQTgzHjC3ABSYwlPtbjPV7jZTERYBu4DXVONHsmgKr/S26f10bFm7FyAeNw8nbuKxatqa6oJiWTOBzZbFg/K+0/PJ7dQZa6qTWFOdOMacCNqlwq2pDRS5LFWn9o72r6TWi7LM7jZT407gJGCXqjWE9Dh6cqypTuxuM1WRF0SHeOOPFbgLOFPg/Lbm+tICU3iMJdQJeneoYtmxQ5LpM+z4S8JRRFQvRcTGNte1vla/H6Ctufa5srmRk6XY2Q/QmyGhbH7NMRjzGNDjWIEVHVvq3u4TpJSbAvvi3h+NaLuqPly+IDobWIpyR6y5dg1A65ba/aFw1Xlxp6CEN+ccuaVaWFgWjt6Y8vPSXL9HUWHA6okbSwa8T6K61BTYfXnyg4UljcCmI2pbrS076w4CB8vC0X2qWW4PCoWUQ25pw+TisorqtyiUaYKepuqZIjqNYxfXBBPXrMnPWreueTpZfKj8xMjnmMSUQ6Euf1k4RvAN1igiYk0FJdZu3kgtb93WsDX15ymza8o1YJ4HJgcCVlVs8+o9A0TNUNE+YyOwD3i4J26mWmKhIv3ku2byVOYofCmlZKqH+sWhcLTvXJfAbgvra/2/IBco+qdHhpD2VIOFmJ+Whas7FZ0CzBGRmxMVRgdxxdBZimkHKQGmCbo71469tHVRboOtpv/vIem/8o3VGMI3WKOIqr4mAmXFgY8Cz/aWhyqiN2OpFdtaf9v0BZWheMBehXKcpUQPbq51yzP+aqypbsnAwoIetjuFdKP6UaDvSqyy+dURVf2crYHvpaQOfjbWVNeXTSFUEb0NyXpha5dRswzAFvu/FSa1To71T6QnfDm2te6JLDJ+BbpXYL+q9bvW5tqNiQdj70cMoH1LseLdzEwKHWBsnatjzY2vApSFq65SkbuL5yz/Uef21TuzjNuPzsmxfcFDpS2WJTUiIpo8YBucHzlN1PqyUe5qb6r7Q67yfEYO32CNIpZtrVRjbjAq9wfDVd8WkZ2orkDkGlG5CeCwYz8JnCGiD6rIhWXhKACOYUP7trpfJkXN6LecAyybx1p2NuwIVUTvEuHaYLjqPsFalch/rjcDHYeK9n3FRa1cMb3X1ZdVRK9FaAy1llwH/EtvA1G5oCwcDfd1UPa2Ndf1XRyhhvtiLmlrYodjvw+VlOw0IreH5kUnK8Rs+AugW9U8k9pWCZwVClcvEsxkRS4HDheWdMZSmixKfTaKtMaa1tzZT8a6dT1l4ep/UdVvBSuij4Uqoo8LUiZi/T0QDBT1uF1p7zMK+AZrFGndUru/fEG00jFyuyg3oYTA2obw1VhTXe89hMWCrAdZBCzq7WtZmghLENkiiYsRLk6VbXqcXwC0nWD9TWiPsxuVK0A/i3JALH4Vd8zXe8MIgFcU+m/9i7wpsL6gZHJ6ShZL96D0zTham+teLAtX/0CVT0xfUHmXUYnZYq8HFoIsPCJSG4CVqPWuwHpLpDNNNqB71nWEwpWfEOx/wnCLCMXA71Wt89uaazcBqNgtgq4X+CyAQRxR3SZi/V3fNWTCy6JSnvpsBH0VuBPhLVFZb5V09ADEmuu+HQxHDgDXAD9W9BBQL5b19XyvNfMZPv4fKziZ+AhbtL4AAAAASUVORK5CYII=";

const QString ResultsCreater::BLANK_USER_BASE64 = "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"
                                                  "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"
                                                  "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"
                                                  "tkv9p9vbq0XCgVFUeIY6UXX/SdYLnFIuBAQQoIx57zVal9cXjVb7cFgyBknhEB085plQwzDkHGWy+U21tZXV1fK5VKhUCjkc6Zpflzpd4/7nUzN9vFvgyBwXdey7X5v0Ol2a7V6s9WKIkoIURRyyx5QSjnnhqHn87nt7a1nu7u5XFYOO5bZrbeM4pDIytU0zff96tn5+flVfzhklMptgJOvdry5SDDKuOC6rq2vr+3u7FTK5VKpaJomhAghJLfHPbgw46wsnHPuul69Xq83mrV6o9lsyiXlyYtPGhtZRl1X19ZWXrzYX11ZAUAIPqeB0eewvOKQIAQBgGEYBYFfqzdOTs+6vT4AQCVELrPEB3VMhn1jjBVFkemUc7lcPp8rl0ulUiGXy+dyOXy3xipG58ULy7Zdx/VcbzAcdnrdXrdn205EKWOMjo6Sh7eOv4z7EcYYgnBjY31//9nKSkUfa2hpxxmTLLs4xLiLgRC5nttqt1utbqvd7g8GQRBihBWFTHpExvtiGKVMJhVSVaLrhmmapmlommYYhvxWPp8nBH9yO7K8iOe5YRhRymzHCYMgiiLP813Pc103iiI8Afj9zEUGZHDGM5nM2vrKSrlSqZSKhYKua4xzebTIktuMUT0suTgk0iQQQjDGruvWG83rWqPf73ueH0URm2i70sMEwO/2tnAu2/CoZ6CUKopSqZQJIR+LQ+6MEkLYtu04rhACIYwQRgjITD1x4rZ4d6f8olyRB4BjjA3DyJjmykp5e3trbXUFY+z7/iNaFZI8DnHcLjSENKLdXu+6Vq/VG8OhBaYMG28xaczvPiC9yx/HX4EQFvL558/3tne2MqYp+GhT62PoRm7zuMQhhAAQQkIwhDAKI9f3HccdDq1ut9tqd4fDYZyJK3ZW3nzz9/ypo/rjVn5ryCmXThjjQnBd08rlUrlcKhWLuVw2kzFN00AIUcqWze95dx6XOACYmIvGXX4Yhr1ev9PtDS3LcVzXdX3PD8MojEIZZ/XJjXF3SZYBxi1ejLNHym5KespVVdE1TdcNM2PmspliIV8qFvOFPCEkiqJ4b99jlMWoih6dOCa5cUVAiAkWQtiO02y2O52uZdmWZcvR381rfVA4O4SjQy8RgjJXHYLQMPRcLlsoFCrlyupqRdfVKGJSNxPfetw8bnHETGZipJQyRhnjUURt2xkOLdd1B7blOF4UhL7vM36/hEmYEN3QsxkzI+c8hpHNmvlsVmYdJYQQjCGE/KHiW1qeiDgmg2viKQUAMAxDz/PDMHQ9PwxDRml4/+QWCCFFVXVV1TRVommqqioAQMYY44wz/th7kE/yRMQxyeQMU05xkTQscqoLH+CuFoLLVRouD8kQN2dlwCd8pPKyLNnPkDiaRv6vnFNwCMEsUjP+8YLLE+MJiuNjZjgUeKpG4pP8JcTxl3qjM+Tp28aUB5OKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSppKKI2UqqThSpvL/AR/D/5D3nv3NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAABJRU5ErkJggg==";

ResultsCreater::ResultsCreater(QObject* parent)
    : QObject(parent)
{
}

void ResultsCreater::createContinuousResultsHTML(const QString& filePath,
    const QStringList& resList,
    const int recordSize,
    const QString& competitionName,
    const QString& competitionType,
    const QString& competitionDirector,
    const QString& competitionDirectorAvatar,
    const QStringList& competitionArbitr,
    const QStringList& competitionArbitrAvatar,
    const QString& competitionDate,
    const QString& competitionRound,
    const QString& competitionGroupName)
{

    QString html = "";

    QVector<QStringList> rows;
    QStringList classesNames;
    QString categoryData;
    QStringList dataRow;
    QStringList header;

    // list size must be even
    // first half of the array are the classes names, second half is the content for each class

    if (resList.size() % 2) {
        qDebug() << "ResultsCreater::createContinuousResultsHTML() resList.size() % 2 == 1" + QString::number(resList.size() % 2);
        return;
    }

    // get classes names
    int i;
    for (i = 0; i < resList.size() / 2; i++) {

        classesNames.push_back(QString(resList.at(i)).remove("\""));
    }

    // create html
    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(getTranslatedString("html-continuous-results")) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";

    html += "<div class=\"container\">\n";

    // results file header
    html += getResultsHTMLBodyHead(competitionName, competitionType, competitionDirector, competitionDirectorAvatar, competitionArbitr, competitionArbitrAvatar, competitionDate, competitionRound, competitionGroupName);

    header = QStringList() << ("html-continuous-results-order")
                           << ("html-continuous-results-name")
                           << ("html-results-ctnt-tg-shortcut")
                           << ("html-results-ctnt-tp-shortcut")
                           << ("html-results-ctnt-sg-shortcut")
                           << ("html-results-ctnt-altLimits-shortcut")
                           << ("html-results-ctnt-speedSec-shortcut")
                           << ("html-results-ctnt-altSec-shortcut")
                           << ("html-results-ctnt-spaceSec-shortcut")
                           << ("html-results-ctnt-markersOk-shortcut")
                           << ("html-results-ctnt-markersNok-shortcut")
                           << ("html-results-ctnt-markersFalse-shortcut")
                           << ("html-results-ctnt-photosOk-shortcut")
                           << ("html-results-ctnt-photosNok-shortcut")
                           << ("html-results-ctnt-photosFalse-shortcut")
                           << ("html-results-ctnt-landing-shortcut")
                           << ("html-results-ctnt-takeOfF-shortcut")
                           //<< ("html-results-ctnt-circling-shortcut")
                           << ("html-results-ctnt-opposite-shortcut")
                           << ("html-results-ctnt-otherPoints-shortcut")
                           << ("html-results-ctnt-otherPenalty-shortcut")
                           << ("html-results-ctnt-points-shortcut")
                           << ("html-results-ctnt-points1000-shortcut");

    // create legend, skip first two columns - order and name
    int skipCols = 2;
    QStringList headerLegend;
    for (int i = skipCols; i < header.size(); i++) {
        headerLegend.push_back(header.at(i) + "-legend"); // add legend suffix for translation
    }

    // tr legend
    headerLegend = getTranslatedStringList(headerLegend);
    header = getTranslatedStringList(header);

    // add legend into legend array and header row
    for (int i = skipCols; i < header.size(); i++) {

        QString headerItem = header.at(i);
        QString legendItem = headerLegend.at(i - skipCols);

        headerLegend[i - skipCols] = headerItem + " - " + legendItem;
        header[i] = getHeaderItemWithHelp(headerItem, legendItem);
    }

    // results for each category
    for (int j = 0; i < resList.size(); i++, j++) {

        categoryData = resList.at(i);

        // no results for this class
        if (categoryData == "[]") {
            continue;
        }

        int row = 1;

        // add category label
        html += getHTMLH3(classesNames.at(j));

        // add category results header
        rows.append(header);

        // get category results data
        QRegularExpression rx("\\\".*?\\\"", QRegularExpression::DotMatchesEverythingOption);
        QRegularExpressionMatchIterator it = rx.globalMatch(categoryData);
        QString category;
        dataRow.clear();

        int col = 0;

        // get ctnt results data
        while (it.hasNext()) {

            // add row number (order)
            if (dataRow.size() == 0) {

                dataRow.push_back(QString::number(row));
                row++;
            }

            // get data from string
            QRegularExpressionMatch match = it.next();
            if (match.hasMatch()) {

                if (col != 1) { // skip class
                    dataRow.push_back(QString(match.captured(0)).remove("\"") == "-1" ? "" : QString(match.captured(0)).remove("\""));
                } else {
                    category = QString(match.captured(0)).remove("\"") == "-1" ? "" : QString(match.captured(0)).remove("\"");
                }
            }

            // add data to table struct
            if (!(dataRow.size() % (recordSize + 1))) {

                // change name to href for evaluated crews
                if (dataRow[dataRow.size() - 2] != "") {

                    dataRow[1] = "<a href=\"" + dataRow.at(1) + "_" + category + ".html" + "\" class=\"hidden-print\">" + dataRow.at(1) + "</a><div class=\"visible-print-block\">" + dataRow.at(1) + "</div>";
                }

                rows.append(dataRow);
                dataRow.clear();
                col = 0;
            } else {
                col++;
            }
        }

        // echo table and spacer
        html += getHTMLHorizontalTable(rows, QVector<double> { 0.5, 2.1, 0.8, 0.8, 0.8, 1.0, 1.0, 1.0, 1.0 });
    }

    // add legend to html
    html += getPrintOnlyText(headerLegend.join(", "));

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filePath + ".html"), html.toUtf8());
}

void ResultsCreater::createStartListHTML(const QString& filename,
    const QStringList& cntList,
    const QString& competitionName,
    const int utc_offset_sec)
{
    Q_UNUSED(competitionName)
    QJsonDocument jsonResponse;
    QJsonObject jsonObject;
    QString html = "";
    QVector<QStringList> rows;

    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(getTranslatedString("html-start-list")) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";

    html += "<div class=\"container\">\n";
    /*
        html += "<div class=\"row\">\n";
        html += "   <div class=\"col-md-6\">\n";
        html +=         competitionName + "\n";
        html += "   </div>\n";
        html += "   <div class=\"col-md-6\">\n";
        html += "       <span class=\"pull-right\">" + QDate().currentDate().toString("dd.MM.yyyy") + "  " + QTime().currentTime().toString("hh:mm:ss") + "</span>\n";
        html += "   </div>\n";
        html += "</div>\n";
    */

    html += getHTMLH1(getTranslatedString("html-start-list-title"));

    // track points header row
    rows.append(getTranslatedStringList(QStringList() << ("html-startList-order")
                                                      << ("html-continuous-results-name")
                                                      << ("html-results-ctnt-category")
                                                      << ("html-results-ctnt-aircraft-registration")
                                                      << ("html-results-ctnt-speed")
                                                      << ("html-startList-startTimePrepTime")
                                                      << ("html-results-ctnt-startTime")
                                                      << ("html-startList-startTimeVBT")
                                                      << ("html-results-note")));

    for (int i = 0; i < cntList.size(); ++i) {

        jsonResponse = QJsonDocument::fromJson(cntList.at(i).toUtf8());
        jsonObject = jsonResponse.object();

        rows.append(QStringList() << QString::number(i + 1)
                                  << jsonObject["name"].toString()
                                  << jsonObject["category"].toString()
                                  << jsonObject["aircraft_registration"].toString()
                                  << QString::number(jsonObject["speed"].toInt())
                                  << QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimePrepTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")
                                  << "<b>" + QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss") + "</b>"
                                  << QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimeVBT"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")
                                  << "");
    }

    html += getHTMLHorizontalTable(rows, QVector<double> { 0.2 / 9.0, 3.1 / 9.0, 0.4 / 9.0, 0.3 / 9.0, 0.4 / 9.0, 0.7 / 9.0, 0.7 / 9.0, 0.7 / 9.0, 2.5 / 9.0 });

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filename + ".html"), html.toUtf8());
}

void ResultsCreater::createContestantResultsHTML(const QString& filename,
    const QString& cntJSON,
    const QString& competitionName,
    const QString& competitionType,
    const QString& competitionDirector,
    const QString& competitionDirectorAvatar,
    const QStringList& competitionArbitr,
    const QStringList& competitionArbitrAvatar,
    const QString& competitionDate,
    const QString& competitionRound,
    const QString& competitionGroupName,
    const int utc_offset_sec)
{
    QString html = "";
    QStringList trackPointsList;
    QVector<QStringList> rows;

    QJsonDocument jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    QJsonObject jsonObject = jsonResponse.object();

    // no results
    if (jsonObject["name"].toString().length() == 1)
        return;

    int tg_time_measured = 0;
    bool sg_hit_measured = false;
    bool tp_hit_measured = false;
    // QString point_alt_type = "";
    int alt_measured = 0;
    double ctntSpeed = jsonObject["speed"].toDouble();

    html += "<!DOCTYPE html>\n";
    html += "<html lang=\"en\">\n";
    html += getHTMLHeader(jsonObject["name"].toString()) + "\n";

    html += "<body>\n";
    html += getHTMLBodyScript() + "\n";
    html += "<div class=\"container\">\n";

    // results file header
    html += getResultsHTMLBodyHead(competitionName, competitionType, competitionDirector, competitionDirectorAvatar, competitionArbitr, competitionArbitrAvatar, competitionDate, competitionRound, competitionGroupName);

    // results header
    html += "<div class=\"row\">";
    html += "   <div class=\"col-xs-4\">";
    html += getHTMLH3(getTranslatedString("html-results-crew-title"));

    QStringList names = jsonObject["name"].toString().split(" – ");
    if (names.length() >= 1) {

        rows.append(QStringList() << getTranslatedString("html-results-ctnt-pilot") << ("<table>" + getUserTableRowRecordWithAvatar(jsonObject["pilotAvatarBase64"].toString(), names[0]) + "</table>"));
    }
    if (names.length() >= 2) {

        rows.append(QStringList() << getTranslatedString("html-results-ctnt-copilot") << ("<table>" + getUserTableRowRecordWithAvatar(jsonObject["copilotAvatarBase64"].toString(), names[1]) + "</table>"));
    }

    rows.append(QStringList() << getTranslatedString("html-results-ctnt-category") << jsonObject["category"].toString());
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-startTime") << QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss"));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-speed") << QString::number(jsonObject["speed"].toDouble()));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-aircraft-registration") << jsonObject["aircraft_registration"].toString());
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-aircraft-type") << jsonObject["aircraft_type"].toString());

    rows.append(QStringList() << getTranslatedString("html-results-ctnt-classify") << (jsonObject["classify"].toDouble() == 0 ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")));
    rows.append(QStringList() << getTranslatedString("html-results-ctnt-score-points") << (jsonObject["scorePoints"].toDouble() < 0 ? "" : QString::number(jsonObject["scorePoints"].toDouble())));
    // rows.append(QStringList() << getTranslatedString("html-results-ctnt-score-points1000") << (jsonObject["scorePoints1000"].toDouble() < 0 ? "" : QString::number(jsonObject["scorePoints1000"].toDouble())));
    // rows.append(QStringList() << getTranslatedString("html-results-ctnt-class-order") << (jsonObject["classOrder"].toDouble() < 0 ? "" : QString::number(jsonObject["classOrder"].toDouble())));
    html += getHTMLVerticalTable(rows);

    html += "   </div>";
    html += "   <div class=\"col-xs-8\">";

    // trajectory
    QUrl trajectoryImgUrl = QUrl(filename + ".png");
    //    if (!file.file_exists(trajectoryImgUrl)) {
    //        qDebug() << "Image \"" << trajectoryImgUrl << "\" doesn't exists";
    //    }
    html += file.file_exists(trajectoryImgUrl) ? getHTMLResponsiveImage(getImageBase64(trajectoryImgUrl)) : "";

    html += "   </div>";
    html += "</div>";

    // manual values
    html += getHTMLH3(getTranslatedString("html-results-manual-values"));
    rows.append(QStringList() << getBoldText(getTranslatedString("html-results-point-type")) << getBoldText(getTranslatedString("html-results-inserted-value")) << getBoldText(getTranslatedString("html-results-score")));

    // markers
    rows.append(QStringList() << getTranslatedString("html-results-markers") + " " + getItalicText(getTranslatedString("html-results-markers-legend")) << QString::number(jsonObject["markersOk"].toDouble()) + " / " + QString::number(jsonObject["markersNok"].toDouble()) + " / " + QString::number(jsonObject["markersFalse"].toDouble()) << QString::number(jsonObject["markersScore"].toDouble()));
    // photos
    rows.append(QStringList() << getTranslatedString("html-results-photos") + " " + getItalicText(getTranslatedString("html-results-markers-legend")) << QString::number(jsonObject["photosOk"].toDouble()) + " / " + QString::number(jsonObject["photosNok"].toDouble()) + " / " + QString::number(jsonObject["photosFalse"].toDouble()) << QString::number(jsonObject["photosScore"].toDouble()));
    // take off
    rows.append(QStringList() << getTranslatedString("html-results-take-off") + " " + getItalicText(getTranslatedString("html-results-take-off-legend")) << QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTime"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss") + " / " + (jsonObject["startTimeMeasured"].toString() == "" ? " - " : QTime(0, 0, 0).addSecs(addUtcToTime(QTime::fromString(jsonObject["startTimeMeasured"].toString(), "HH:mm:ss"), utc_offset_sec)).toString("HH:mm:ss")) + " / " + (jsonObject["startTimeDifference"].toString() == "" ? " - " : jsonObject["startTimeDifference"].toString()) << QString::number(jsonObject["startTimeScore"].toDouble()));
    // landing accurancy
    rows.append(QStringList() << getTranslatedString("html-results-landing-accurancy") + " " + getItalicText(getTranslatedString("html-results-point-legend")) << QString::number(jsonObject["landingScore"].toDouble()) << QString::number(jsonObject["landingScore"].toDouble()));
    // circling
    // rows.append(QStringList() << getTranslatedString("html-results-circling") + " " + getItalicText(getTranslatedString("html-results-count-legend")) <<
    //            QString::number(jsonObject["circlingCount"].toDouble()) <<
    //            QString::number(jsonObject["circlingScore"].toDouble()));
    // opposite dir flight
    rows.append(QStringList() << getTranslatedString("html-results-opposite") + " " + getItalicText(getTranslatedString("html-results-count-legend")) << QString::number(jsonObject["oppositeCount"].toDouble()) << QString::number(jsonObject["oppositeScore"].toDouble()));
    // other points
    rows.append(QStringList() << getTranslatedString("html-results-other-points") + " " + getItalicText(getTranslatedString("html-results-point-legend")) << QString::number(jsonObject["otherPoints"].toDouble()) << QString::number(jsonObject["otherPoints"].toDouble()));
    // other penalty
    rows.append(QStringList() << getTranslatedString("html-results-other-penalty") + " " + getItalicText(getTranslatedString("html-results-point-legend")) << QString::number(jsonObject["otherPenalty"].toDouble()) << QString::number(jsonObject["otherPenalty"].toDouble() != 0 ? jsonObject["otherPenalty"].toDouble() * -1 : 0));
    // note
    rows.append(QStringList() << getTranslatedString("html-results-note") << jsonObject["pointNote"].toString() << "-");

    html += getHTMLVerticalTable(rows);

    // track points
    if (jsonObject["wptScoreDetails"].toString() != "") {

        trackPointsList = jsonObject["wptScoreDetails"].toString().split("; ");

        html += getHTMLH3(getTranslatedString("html-results-track-points"));

        // track points header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-point-name")
                                                          << ("html-results-point-type")
                                                          << ("html-results-point-distance")
                                                          << ("html-results-point-tg-expected")
                                                          << ("html-results-point-tg-measured")
                                                          //<< ("html-results-point-tg-difference")
                                                          //<< ("html-results-tg-score")
                                                          << ("html-results-point-tp-hit")
                                                          //<< ("html-results-tp-score")
                                                          << ("html-results-point-sg-hit")
                                                          //<< ("html-results-sg-score")
                                                          << ("html-results-point-alt-limit")
                                                          //<< ("html-results-point-alt-min")
                                                          //<< ("html-results-point-alt-max")
                                                          << ("html-results-point-alt-measured")
                                                          //<< ("html-results-alt-score")
                                                          << ("html-results-score")));

        // track points content
        for (int k = 0; k < trackPointsList.size(); ++k) {
            jsonResponse = QJsonDocument::fromJson(trackPointsList.at(k).toUtf8());
            jsonObject = jsonResponse.object();

            tg_time_measured = jsonObject["tg_time_manual"].toDouble() < 0 ? jsonObject["tg_time_measured"].toDouble() : jsonObject["tg_time_manual"].toDouble();
            sg_hit_measured = jsonObject["sg_hit_manual"].toDouble() < 0 ? jsonObject["sg_hit_measured"].toBool() : jsonObject["sg_hit_manual"].toBool();
            tp_hit_measured = jsonObject["tp_hit_manual"].toDouble() < 0 ? jsonObject["tp_hit_measured"].toBool() : jsonObject["tp_hit_manual"].toBool();
            alt_measured = jsonObject["alt_manual"].toDouble() < 0 ? jsonObject["alt_measured"].toDouble() : jsonObject["alt_manual"].toDouble();

            // check point type
            bool isTG = (int(jsonObject["type"].toDouble()) & 2) == 2;
            bool isTP = (int(jsonObject["type"].toDouble()) & 1) == 1;
            bool isSG = (int(jsonObject["type"].toDouble()) & 4) == 4;
            bool altLimit = ((jsonObject["alt_min"].toDouble() > 0) || (jsonObject["alt_max"].toDouble() > 0));

            rows.append(QStringList() << jsonObject["title"].toString()
                                      << pointFlagToString(jsonObject["type"].toDouble())
                                      << QString::number(jsonObject["distance_from_vbt"].toDouble() / 1000, 'f', 2)

                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + QTime(0, 0, 0).addSecs(addUtcToTime(jsonObject["tg_time_calculated"].toDouble(), utc_offset_sec)).toString("HH:mm:ss") + (isTG ? "" : getFontColorEndTag())
                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + QTime(0, 0, 0).addSecs(addUtcToTime(tg_time_measured, utc_offset_sec)).toString() + (isTG ? "" : getFontColorEndTag())
                                      << (isTP ? "" : getFontColorStartTag("#bfbfbf")) + (tp_hit_measured ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")) + (isTP ? "" : getFontColorEndTag())
                                      << (isSG ? "" : getFontColorStartTag("#bfbfbf")) + (sg_hit_measured ? getTranslatedString("hit-yes") : getTranslatedString("hit-no")) + (isSG ? "" : getFontColorEndTag())
                                      << ((jsonObject["alt_min"].toDouble() < 0 ? "GND" : QString::number(jsonObject["alt_min"].toDouble())) + " - " + (jsonObject["alt_max"].toDouble() < 0 ? "FL 660" : QString::number(jsonObject["alt_max"].toDouble())))
                                      << (alt_measured < 0 ? "" : QString::number(alt_measured))

                                      << (isTG ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["tg_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["tg_score"].toDouble())) + (isTG ? "" : getFontColorEndTag())
                                      << (isTP ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["tp_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["tp_score"].toDouble())) + (isTP ? "" : getFontColorEndTag())
                                      << (isSG ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["sg_score"].toDouble() < 0 ? "0" : QString::number(jsonObject["sg_score"].toDouble())) + (isSG ? "" : getFontColorEndTag())
                                      << (altLimit ? "" : getFontColorStartTag("#bfbfbf")) + (jsonObject["alt_score"].toDouble() == -1 ? "0" : QString::number(jsonObject["alt_score"].toDouble())) + (altLimit ? "" : getFontColorEndTag()));
        }
        html += getHTMLHorizontalTable(rows);
    }

    // speed sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    QRegularExpression rx("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    QRegularExpressionMatchIterator i = rx.globalMatch(jsonObject["speedSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-speed-sections"));

        // speed sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-speed-sec-start-point")
                                                          << ("html-results-speed-sec-end-point")
                                                          << ("html-results-speed-sec-expected")
                                                          << ("html-results-speed-sec-measured")
                                                          << ("html-results-score")));

        // speed sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                jsonObject = jsonResponse.object();

                rows.append(QStringList() << jsonObject["startPointName"].toString()
                                          << jsonObject["endPointName"].toString()
                                          << QString::number(ctntSpeed)
                                          << (jsonObject["manualSpeed"].toDouble() < 0 ? QString::number(jsonObject["calculatedSpeed"].toDouble()) : QString::number(jsonObject["manualSpeed"].toDouble()))
                                          << QString::number(jsonObject["speedSecScore"].toDouble()));
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double> { 1.0 / 7.0, 1.0 / 7.0, 1.0 / 7.0, 1.0 / 7.0, 1.0 / 7.0, 2.0 / 7.0 });
    }

    // altitude sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    rx = QRegularExpression("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    i = rx.globalMatch(jsonObject["altitudeSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-altitude-sections"));

        // alt sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-alt-sec-start-point")
                                                          << ("html-results-alt-sec-end-point")
                                                          << ("html-results-alt-sec-min-count")
                                                          << ("html-results-alt-sec-min-time")
                                                          << ("html-results-alt-sec-max-count")
                                                          << ("html-results-alt-sec-max-time")
                                                          << ("html-results-score")));
        // alt sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                jsonObject = jsonResponse.object();

                rows.append(QStringList() << jsonObject["startPointName"].toString()
                                          << jsonObject["endPointName"].toString()
                                          << (jsonObject["manualAltMinEntriesCount"].toDouble() < 0 ? QString::number(jsonObject["altMinEntriesCount"].toDouble()) : QString::number(jsonObject["manualAltMinEntriesCount"].toDouble()))
                                          << (jsonObject["manualAltMinEntriesCount"].toDouble() < 0 ? (jsonObject["manualAltMinEntriesTime"].toDouble() < 0 ? QTime(0, 0, 0).addSecs(jsonObject["altMinEntriesTime"].toDouble()).toString("hh:mm:ss") : QTime(0, 0, 0).addSecs(jsonObject["manualAltMinEntriesTime"].toDouble()).toString("hh:mm:ss")) : "")
                                          << (jsonObject["manualAltMaxEntriesCount"].toDouble() < 0 ? QString::number(jsonObject["altMaxEntriesCount"].toDouble()) : QString::number(jsonObject["manualAltMaxEntriesCount"].toDouble()))
                                          << (jsonObject["manualAltMaxEntriesCount"].toDouble() < 0 ? (jsonObject["manualAltMaxEntriesTime"].toDouble() < 0 ? QTime(0, 0, 0).addSecs(jsonObject["altMaxEntriesTime"].toDouble()).toString("hh:mm:ss") : QTime(0, 0, 0).addSecs(jsonObject["manualAltMaxEntriesTime"].toDouble()).toString("hh:mm:ss")) : "")
                                          << QString::number(jsonObject["altSecScore"].toDouble()));
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double> { 1, 1, 1, 1, 1, 1, 1 });
    }

    // space sections
    jsonResponse = QJsonDocument::fromJson(cntJSON.toUtf8());
    jsonObject = jsonResponse.object();

    // split array
    rx = QRegularExpression("\\{.*?\\}", QRegularExpression::DotMatchesEverythingOption);
    i = rx.globalMatch(jsonObject["spaceSectionsScoreDetails"].toString());

    if (i.hasNext()) {

        html += getHTMLH3(getTranslatedString("html-results-space-sections"));

        // alt sections header row
        rows.append(getTranslatedStringList(QStringList() << ("html-results-space-sec-start-point")
                                                          << ("html-results-space-sec-end-point")
                                                          << ("html-results-space-sec-entries-count")
                                                          << ("html-results-space-sec-entries-time")
                                                          << ("html-results-score")));
        // alt sections content
        while (i.hasNext()) {
            QRegularExpressionMatch match = i.next();
            if (match.hasMatch()) {

                jsonResponse = QJsonDocument::fromJson(match.captured(0).toUtf8());
                jsonObject = jsonResponse.object();

                rows.append(QStringList() << jsonObject["startPointName"].toString()
                                          << jsonObject["endPointName"].toString()
                                          << (jsonObject["manualEntries_out"].toDouble() < 0 ? QString::number(jsonObject["entries_out"].toDouble()) : QString::number(jsonObject["manualEntries_out"].toDouble()))
                                          << (jsonObject["manualEntries_out"].toDouble() < 0 ? (jsonObject["manualTime_spent_out"].toDouble() < 0 ? QTime(0, 0, 0).addSecs(jsonObject["time_spent_out"].toDouble()).toString("hh:mm:ss") : QTime(0, 0, 0).addSecs(jsonObject["manualTime_spent_out"].toDouble()).toString("hh:mm:ss")) : "")
                                          << QString::number(jsonObject["spaceSecScore"].toDouble()));
            }
        }

        html += getHTMLHorizontalTable(rows, QVector<double> { 1.0 / 7.0, 1.0 / 7.0, 1.0 / 7.0, 1.0 / 7.0, 3.0 / 7.0 });
    }

    html += "</div>\n";
    html += "</body>\n";
    html += "</html>\n";

    file.writeUTF8(QUrl(filename + ".html"), html.toUtf8());
}

const inline QString ResultsCreater::getFontColorStartTag(QString color)
{

    if (color == "#bfbfbf") // grey color
        return "<span style=\"color:" + color + "\" class=\"greyText !important\">";
    else
        return "<span style=\"color:" + color + "\">";
}

const inline QString ResultsCreater::getFontColorEndTag()
{

    return "</span>";
}

const inline QString ResultsCreater::getBoldText(const QString text)
{

    return "<b>" + text + "</b>";
}

const inline QString ResultsCreater::getItalicText(const QString text)
{

    return "<i>" + text + "</i>";
}

const QString ResultsCreater::getItalicGreyText(const QString text)
{

    return getItalicText(getFontColorStartTag("#bfbfbf") + text + getFontColorEndTag());
}

const QString ResultsCreater::getResultsHTMLBodyHead(const QString& competitionName,
    const QString& competitionType,
    const QString& competitionDirector,
    const QString& competitionDirectorAvatar,
    const QStringList& competitionArbitr,
    const QStringList& competitionArbitrAvatar,
    const QString& competitionDate,
    const QString& competitionRound,
    const QString& competitionGroupName)
{

    QString html = "";
    QVector<QStringList> rows;

    html += getHTMLH1(competitionName);
    html += "<div class=\"row\">\n";
    html += "   <div class=\"col-xs-4\">\n";

    if (competitionGroupName != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-group-name") << competitionGroupName);

    if (competitionRound != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-round") << competitionRound);

    if (competitionType != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-type") << competitionType);

    if (competitionDate != "")
        rows.append(QStringList() << getTranslatedString("html-results-competition-date") << competitionDate);

    html += getHTMLVerticalTable(rows);
    html += "   </div>\n";

    html += "   <div class=\"col-xs-4\">\n";

    if (competitionDirector != "") {
        rows.append(QStringList() << getTranslatedString("html-results-competition-director") << ("<table>" + getUserTableRowRecordWithAvatar(competitionDirectorAvatar, competitionDirector) + "</table>"));
    }

    // push each arbitr with avatar into table
    for (int i = 0; i < competitionArbitr.size(); i++) {

        QString avatar = i < competitionArbitrAvatar.size() ? competitionArbitrAvatar.at(i) : BLANK_USER_BASE64;
        QString label = (i == 0 ? getTranslatedString("html-results-competition-arbitr") : "");

        if (competitionArbitr.at(i) != "") {
            rows.append(QStringList() << label << ("<table>" + getUserTableRowRecordWithAvatar(avatar, competitionArbitr.at(i)) + "</table>"));
        }
    }

    html += getHTMLVerticalTable(rows);
    html += "   </div>\n";

    html += "   <div class=\"col-xs-4\">\n";
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">\n";
    html += getHTMLRoundedImage(ResultsCreater::LAA_LOG_BASE64, "50px", "auto");
    html += "           </span>\n";
    html += "       </div>\n";
    html += getHTMLSpace(5);
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">" + QDate().currentDate().toString("yyyy-MM-dd ") + "</span>\n";
    html += "       </div>\n";
    html += "       <div class=\"row\">\n";
    html += "           <span class=\"pull-right\">" + QTime().currentTime().toString("hh:mm:ss ") + "</span>\n";
    html += "       </div>\n";
    html += "   </div>\n";
    html += "</div>\n";

    return html;
}

const QString ResultsCreater::getHTMLHorizontalTable(QVector<QStringList>& rows, const QVector<double>& preferedColumnsWidth)
{

    QString htmlTable = "";
    QStringList rowItem;
    QString columnWidthString = "";
    QString headerLastColColSpan = "";

    // calc colspan for header last column
    if ((rows.size() > 1) && (rows.at(0).size() < rows.at(1).size())) {
        headerLastColColSpan = " colspan=\"" + QString::number(rows.at(1).size() - rows.at(0).size() + 1) + "\"";
    }

    htmlTable += getHTMLStartTableTag() + "\n";

    for (int i = 0; i < rows.size(); ++i) {

        rowItem = QStringList(rows.at(i));

        // table content
        htmlTable += "<tr>\n";

        for (int j = 0; j < rowItem.size(); ++j) {

            if (preferedColumnsWidth.size() == rowItem.size()) {

                columnWidthString = " style=\"width: " + QString::number(preferedColumnsWidth.at(j) * 100 / rowItem.size()) + "%\"";
            }

            if (i == 0)
                htmlTable += "   <th" + (columnWidthString != "" ? columnWidthString : (j == (rowItem.size() - 1) ? headerLastColColSpan : "")) + ">" + rowItem.at(j) + "</th>\n";
            else
                htmlTable += "   <td" + columnWidthString + ">" + rowItem.at(j) + "</td>\n";
        }

        htmlTable += "</tr>\n";
    }

    htmlTable += getHTMLEndTableTag() + "\n";

    rows.clear();

    return htmlTable;
}

const QString ResultsCreater::getHTMLVerticalTable(QVector<QStringList>& rows)
{

    QString htmlTable = "";
    QStringList rowItem;

    htmlTable += getHTMLStartTableTag() + "\n";

    for (int i = 0; i < rows.size(); ++i) {

        rowItem = QStringList(rows.at(i));

        // table content
        htmlTable += "<tr>\n";

        for (int j = 0; j < rowItem.size(); ++j) {

            htmlTable += "   <td>" + rowItem.at(j) + "</td>\n";
        }

        htmlTable += "</tr>\n";
    }

    htmlTable += getHTMLEndTableTag() + "\n";

    rows.clear();

    return htmlTable;
}

const inline QString ResultsCreater::getHTMLH1(const QString text)
{

    return "<h1>" + text + "</h1>";
}

const inline QString ResultsCreater::getHTMLH2(const QString text)
{

    return "<h2>" + text + "</h2>";
}

const inline QString ResultsCreater::getHTMLH3(const QString text)
{

    return "<h3>" + text + "</h3>";
}

const inline QString ResultsCreater::getHTMLHeader(const QString title)
{

    return "<head>\n"
           "<meta charset=\"UTF-8\">\n"
           "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
           "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" />\n"
           "<meta name=\"description\" content=\"\">\n"
           "<meta name=\"author\" content=\"Letecká Amaterská Asociace ČR\">\n"
           "<meta property=\"og:title\" content=\""
        + title + "\"/>\n"

                  "<title>"
        + title + "</title>\n"

                  "<!-- Bootstrap core CSS -->\n"
                  "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">\n"
                  "<link href=\"../bin/viewer+/x64/www/css/style.css\" rel=\"stylesheet\">\n"
                  "<link href=\"../bin/viewer+/x86/www/css/style.css\" rel=\"stylesheet\">\n"

                  "<style>"
                  "@media print {"
                  ".table-startlist > tbody > tr > td, .table-startlist > tbody > tr > th, .table-startlist > tfoot > tr > td, .table-startlist > tfoot > tr > th, .table-startlist > thead > tr > td, .table-startlist > thead > tr > th"
                  "{"
                  "padding: 3px;"
                  "}"
                  ".greyText {"
                  "color: #ccc !important;"
                  "},"

                  ".col-xs-1,"
                  ".col-xs-2,"
                  ".col-xs-3,"
                  ".col-xs-4,"
                  ".col-xs-5,"
                  ".col-xs-6,"
                  ".col-xs-7,"
                  ".col-xs-8,"
                  ".col-xs-9,"
                  ".col-xs-10,"
                  ".col-xs-11,"
                  ".col-xs-12 {"
                  "   float: none;"
                  "   width: 100%;"
                  "}"

                  ".container {"
                  "   width: auto;"
                  "}"
                  "}"
                  "</style>"

                  "</head>\n"
                  "\n";
}

const inline QString ResultsCreater::getHTMLBodyScript()
{

    return "<!-- Placed at the end of the document so the pages load faster -->\n"

           "<script>\n"
           "<type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js\">\n"
           "<type=\"text/javascript\" src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\">\n"
           "<type=\"text/javascript\" src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/selectize.min.js\">\n"

           "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/jquery.min.js\">\n"
           "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/bootstrap.min.js\">\n"
           "<type=\"text/javascript\" src=\"../bin/viewer+/x86/www/js/selectize.min.js\">\n"

           "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/jquery.min.js\">\n"
           "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/bootstrap.min.js\">\n"
           "<type=\"text/javascript\" src=\"../bin/viewer+/x64/www/js/selectize.min.js\">\n"
           "</script>\n"

           "<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->\n"
           "\n";
}

const inline QString ResultsCreater::getImageBase64(const QUrl& image)
{

    return QString(file.read(image).toBase64());
}

const inline QString ResultsCreater::getHTMLResponsiveImage(const QString& base64)
{

    return "<img class=\"img-responsive\" src=\"data:image/png;base64," + base64 + "\">";
}

const inline QString ResultsCreater::getHTMLRoundedImage(const QString& base64, const QString heightPx, const QString widthPx)
{

    return "<img style=\"height: " + heightPx + "; width: " + widthPx + ";\" class=\"img-rounded\" src=\"data:image/png;base64," + base64 + "\">";
}

const inline QString ResultsCreater::getHTMLStartTableTag()
{

    return "<table class=\"table table-striped table-startlist\">";
}

const inline QString ResultsCreater::getHTMLEndTableTag()
{

    return "</table>";
}

const inline QString ResultsCreater::getHTMLSpace(const int spaceInPx)
{

    return "<div class=\"col-xs-12\" style=\"height:" + QString::number(spaceInPx) + "px;\"></div>";
}

const inline QString ResultsCreater::getUserTableRowRecordWithAvatar(const QString& avatarBase64,
    const QString& name)
{

    QString avatar = avatarBase64 == "" ? BLANK_USER_BASE64 : avatarBase64;

    return "<tr><td style=\"width:50px; height:42px\">" + getHTMLRoundedImage(avatar, "40px", "40px") + "</td><td>" + name + "</td></tr>";
}

const inline QString ResultsCreater::getHeaderItemWithHelp(const QString shortcut, const QString help)
{

    return "<abbr class=\"hidden-print\" title=\"" + help + "\">" + shortcut + "</abbr><span class=\"visible-print-inline\">" + shortcut + "</span>";
}

const inline QString ResultsCreater::getPrintOnlyText(const QString text)
{

    return "<span class=\"visible-print-inline\">" + text + "</span>";
}

const QStringList ResultsCreater::getTranslatedStringList(QStringList sourceList)
{

    // load qml component, used for localization
    QVariant returnedValue;
    QStringList translatedList;
    QQmlEngine engine;
    QQmlComponent component(&engine, QStringLiteral("qrc:/src/qml/components/MyTranslator.qml"));
    QObject* object = component.create();

    for (int i = 0; i < sourceList.length(); i++) {

        QMetaObject::invokeMethod(object, "myTranslate", Q_RETURN_ARG(QVariant, returnedValue), Q_ARG(QVariant, sourceList.at(i)));
        translatedList.push_back(returnedValue.toString());
    }

    delete object;

    return translatedList;
}

const QString ResultsCreater::getTranslatedString(QString sourceString)
{

    return getTranslatedStringList(QStringList() << sourceString).join("");
}

int ResultsCreater::timeToSec(const QTime& time)
{

    return QTime(0, 0, 0).secsTo(time);
}

int ResultsCreater::addUtcToTime(const int timeSec, const int utcOffsetSec)
{

    if (timeSec <= 0) {
        return 0;
    } else {
        return timeSec + utcOffsetSec;
    }
}

int ResultsCreater::addUtcToTime(const QTime& time, const int utcOffsetSec)
{

    int timeSec = timeToSec(time);

    if (timeSec <= 0) {
        return 0;
    } else {
        return timeSec + utcOffsetSec;
    }
}

int ResultsCreater::subUtcFromTime(const int timeSec, const int utcOffsetSec)
{

    if (timeSec <= 0) {
        return 0;
    } else {
        return timeSec - utcOffsetSec;
    }
}

int ResultsCreater::subUtcFromTime(const QTime& time, const int utcOffsetSec)
{

    int timeSec = timeToSec(time);

    if (timeSec <= 0) {
        return 0;
    } else {
        return timeSec - utcOffsetSec;
    }
}

QString ResultsCreater::pointFlagToString(const unsigned int f)
{

    // original functions was in function.js and ScoreListTableDelegate.qml

    QStringList str;

    QVector<bool> arr;
    unsigned int nMask = f | 0x10000;

    // nMask must be between -2147483648 and 2147483647
    if (nMask > 0x7fffffff) {
        return "ERR - invalid mask value1";
    }
    for (int nShifted = nMask; nShifted;) {

        arr.push_back(bool(nShifted & 1));
        nShifted >>= 1;
    }

    if (arr[0]) {
        // "TP"
        str.push_back("track-list-delegate-ob-short");
    }
    if (arr[1]) {
        // "TG"
        str.push_back("track-list-delegate-tg-short");
    }
    if (arr[2]) {
        // "SG"
        str.push_back("track-list-delegate-sg-short");
    }
    if (arr[3]) {
        // "ALT_MIN"
        str.push_back("track-list-delegate-alt_min-short");
    }
    if (arr[4]) {
        // "ALT_MAX"
        str.push_back("track-list-delegate-alt_max-short");
    }
    if (arr[5]) {
        // "SPD_MIN"
        str.push_back("track-list-delegate-speed_min-short");
    }
    if (arr[6]) {
        // "SPD_MAX"
        str.push_back("track-list-delegate-speed_max-short");
    }
    if (arr[7]) {
        // "sss"
        str.push_back("track-list-delegate-section_speed_start-short");
    }
    if (arr[8]) {
        // "sse"
        str.push_back("track-list-delegate-section_speed_end-short");
    }
    if (arr[9]) {
        // "sas"
        str.push_back("track-list-delegate-section_alt_start-short");
    }
    if (arr[10]) {
        // "sae"
        str.push_back("track-list-delegate-section_alt_end-short");
    }
    if (arr[11]) {
        // "sws"
        str.push_back("track-list-delegate-section_space_start-short");
    }
    if (arr[12]) {
        // "swe"
        str.push_back("track-list-delegate-section_space_end-short");
    }
    if (arr[13]) {
        // "sec_tp"
        str.push_back("track-list-delegate-secret-turn-point-short");
    }
    if (arr[14]) {
        // "sec_tg"
        str.push_back("track-list-delegate-secret-time-gate-short");
    }
    if (arr[15]) {
        // "sec_sg"
        str.push_back("track-list-delegate-secret-space-gate-short");
    }

    return getTranslatedStringList(str).join(", ");
}
