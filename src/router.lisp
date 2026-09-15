; Use html:add-page to define routes and their contents here. 
(print "=== ROUTER SCRIPT ===")
(html:add-page "/" (pages:page-home))
(html:add-page "/test-page" "<p><em>THIS IS THE TEST PAGE</em></p>")
(html:add-page "/e/2021" (pages:page-2021))
(html:add-page "/e/2022" (pages:page-2022))
(html:add-page "/e/2023" (pages:page-2023))
(html:add-page "/e/2025" (pages:page-2025))
(html:add-page "/e/2026" (pages:page-2026))

