resource "tailscale_acl" "as_hujson" {
  acl = <<EOF
  // Example/default ACLs for unrestricted connections.
  {
  	// Declare static groups of users. Use autogroups for all users or users with a specific role.
  	// "groups": {
  	//   "group:example": ["alice@example.com", "bob@example.com"],
  	// },
  
  	// Define the tags which can be applied to devices and by which users.
  	// "tagOwners": {
  	//   "tag:example": ["autogroup:admin"],
  	// },
  
  	// Define grants that govern access for users, groups, autogroups, tags,
  	// Tailscale IP addresses, and subnet ranges.
  	"grants": [
  		// Allow all connections.
  		// Comment this section out if you want to define specific restrictions.
  		{
  			"src": ["*"],
  			"dst": ["*"],
  			"ip":  ["*"],
  		},
  
  		// Allow users in "group:example" to access "tag:example", but only from
  		// devices that are running macOS and have enabled Tailscale client auto-updating.
  		// {"src": ["group:example"], "dst": ["tag:example"], "ip": ["*"], "srcPosture":["posture:autoUpdateMac"]},
  	],
  
  	// Define postures that will be applied to all rules without any specific
  	// srcPosture definition.
  	// "defaultSrcPosture": [
  	//      "posture:anyMac",
  	// ],
  
  	// Define device posture rules requiring devices to meet
  	// certain criteria to access parts of your system.
  	// "postures": {
  	//      // Require devices running macOS, a stable Tailscale
  	//      // version and auto update enabled for Tailscale.
  	//  "posture:autoUpdateMac": [
  	//      "node:os == 'macos'",
  	//      "node:tsReleaseTrack == 'stable'",
  	//      "node:tsAutoUpdate",
  	//  ],
  	//      // Require devices running macOS and a stable
  	//      // Tailscale version.
  	//  "posture:anyMac": [
  	//      "node:os == 'macos'",
  	//      "node:tsReleaseTrack == 'stable'",
  	//  ],
  	// },
  
  	// Define users and devices that can use Tailscale SSH.
  	"ssh": [
  		{
  			"src":    ["autogroup:members", "autogroup:tagged"],
  			"dst":    ["tag:ts-ssh-enabled"],
  			"users":  ["autogroup:nonroot", "root"],
  			"action": "accept",
  		},
  	],
  
  	"tagOwners": {
  		// Tailscale subnet-routers which don't need approval to advertise routes in the tailnet
  		"tag:auto-subnet-routers": [],
  
  		// Nodes that are allowed to use ts-ssh
  		"tag:ts-ssh-enabled": [],
  
  		// Devices deployed in Toronto
  		"tag:Toronto": [],
  
  		// Devices deployed in New York
  		"tag:NewYork": [],
  	},
  
  	"groups":        {},
  	"autoApprovers": {"routes": {"0.0.0.0/0": ["tag:auto-subnet-routers"]}},
  
  	// Test access rules every time they're saved.
  	// "tests": [
  	//   {
  	//       "src": "alice@example.com",
  	//       "accept": ["tag:example"],
  	//       "deny": ["100.101.102.103:443"],
  	//   },
  	// ],
  }
  EOF
}