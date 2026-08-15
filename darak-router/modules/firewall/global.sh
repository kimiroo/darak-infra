# Drop firewall global rules
delete firewall global-options

# Apply firewall global rules
set firewall global-options state-policy established action 'accept'
set firewall global-options state-policy related action 'accept'