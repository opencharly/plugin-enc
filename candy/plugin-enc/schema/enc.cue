// plugin-enc's OWN self-contained CUE schema — the plugin's declaration
// surface, served over Describe exactly like every other plugin's schema
// (there is no schema-less plugin):
//
//  1. SERVE over Describe — the host splices `base ++ plugin` at the load gate
//     (registerPluginUnitSchema), so the plugin's declarations travel WITH it and
//     a self-contained schema that will not splice is a LOUD load failure.
//  2. DOCUMENT — `charly docs generate` renders this plugin's page from its
//     providers + this schema + the candy `description:`.
//
// verb:enc's authored input is NOT a plugin_input: charly's in-core shim host-prelifts
// the resolved encrypted-volume plan into a structured spec.EncExecInput and Invokes
// OpExecute with it, so this schema DOCUMENTS the verb contract (no #*Input def).
// SELF-CONTAINED: it references no base def, so it compiles STANDALONE (the property
// that lets the SDK compile it serve-side).
#EncPlugin: {
	// The capability word the plugin serves.
	verb: "enc"

	// What the verb does, in one line (the public-docs surface): run the
	// gocryptfs/systemd mechanics that mount, unmount, init, and re-key charly's
	// gocryptfs-backed encrypted volumes.
	contract: string & !=""
}
