; Use html:add-page to define routes and their contents here. 
(print "=== ROUTER SCRIPT ===")
(html:add-page "/" (pages:page-home))
(html:add-page "/test-page" "<p><em>THIS IS THE TEST PAGE</em></p>")
(html:add-page "/e/2025" (pages:page-2025))

