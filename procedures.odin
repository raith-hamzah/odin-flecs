package flecs

import "core:c"

when ODIN_OS == .Darwin {
	foreign import flecs "../lib/libflecs_static.a"
}

@(default_calling_convention = "c", link_prefix = "ecs_")
foreign flecs {
	// world api
	init :: proc() -> ^World ---
	mini :: proc() -> ^World ---
	init_w_args :: proc(argc: c.int, argv: []cstring) -> ^World ---
	fini :: proc(world: ^World) -> c.int ---
	is_fini :: proc(world: ^World) -> c.bool ---
	atfini :: proc(world: ^World, action: fini_action) -> ^World ---
	run_post_frame :: proc(world: ^World, action: fini_action, ctx: rawptr) ---
	quit :: proc(world: ^World) ---
	should_quit :: proc(world: ^World) -> c.bool ---
	set_hooks_id :: proc(world: ^World, id: Entity, hooks: ^Type_Hooks) ---
	get_hooks_id :: proc(world: ^World, id: Entity) -> ^Type_Hooks ---
	set_context :: proc(world: ^World, ctx: rawptr) ---
	get_context :: proc(world: ^World) -> rawptr ---
	get_world_info :: proc(world: ^World) -> ^World_Info ---
	dim :: proc(world: ^World, entity_count: c.int32) ---
	set_entity_range :: proc(world: ^World, id_start: Entity, id_end: Entity) ---
	set_entity_generation :: proc(world: ^World, entity_with_generation: Entity) ---
	enable_range_check :: proc(world: ^World, enable: c.bool) -> c.bool
	measure_frame_time :: proc(world: ^World, enable: c.bool) ---
	measure_system_time :: proc(world: ^World, enable: c.bool) ---
	set_target_fps :: proc(world: ^World, fps: ftime) ---
	run_aperiodic :: proc(world: ^World, flags: flags32) ---
	delete_empty_tables :: proc(
		world: ^World,
		id: id,
		clear_generation: c.uint16,
		delete_generation: c.uint16,
		min_id_count: c.int32,
		time_budget_seconds: c.double,
	) -> c.int32 ---
	_poly_is :: proc(object: Poly, ype: c.int32) -> c.bool ---
	// creating entitites
	new_id :: proc(world: ^World) -> Entity ---
	new_low_id ::  proc(world: ^World) -> Entity ---
	new_w_id :: proc(world: ^World, id: id) -> Entity ---
	entity_init :: proc(world: ^World, desc: ^Entity_Desc) -> Entity ---
	bulk_init :: proc(world: ^World, desc: ^Bulk_Desc) -> [^]entity ---
	component_init :: proc(world: ^World, desc: ^Component_Desc) -> Entity ---
	bulk_new_w_id :: proc(world: ^World, id: id, count: c.int32) -> [^]entity ---
	clone :: proc(world: ^World, dst: Entity, src: Entity, copy_value: c.bool) -> Entity ---
	// adding / removing components
	add_id :: proc(world: ^World, entity: Entity, id: id) ---
	remove_id :: proc(world: ^World, entity: Entity, id: id) ---
	override_id :: proc(world: ^World, entity: Entity, id: id ) ---
	// enabling / disabling components
	enable_id :: proc(world: ^World, entity: Entity, id: id, enable: c.bool) ---
	is_enabled_id :: proc(world: ^World, entity: Entity, id: id) -> c.bool---
	// pairs
	make_pair :: proc(first: Entity, second: Entity) -> id ---
	// deleting entities and components
	clear :: proc(world: ^World, entity: Entity) ---
	delete :: proc(world: ^World, entity: Entity) ---
	delete_with :: proc(world: ^World, id: id) ---
	remove_all :: proc(world: ^World, id: id) ---
	// getting components
	get_id :: proc(world: ^World, entity: Entity, id: id) -> rawptr ---
	ref_init_id :: proc(world: ^World, entity: Entity, id: id) -> ref ---
	ref_get_id :: proc(world: ^World, ref: ^Ref, id: id) -> rawptr ---
	// setting components
	get_mut_id :: proc(world: ^World, entity: Entity, id: id) -> rawptr ---
	write_begin :: proc(world: ^World, entity: Entity) -> ^Record ---
	write_end :: proc(record: ^Record) ---
	read_begin :: proc(world: ^World, entity: Entity) -> ^Record ---
	read_end :: proc(record: ^Record) ---
	record_get_mut_id :: proc(world: ^World, record: ^Record, id: id) -> rawptr ---
	emplace_id :: proc(world: ^World, entity: Entity, id : id) -> rawptr ---
	modified_id ::  proc(world: ^World, entity: Entity, id : id) ---
	set_id ::  proc(world: ^World, entity: Entity, id : id, size: c.size, ptr: rawptr) -> Entity ---
	// entity metadata
	is_valid :: proc(world: ^World, entity: Entity) -> c.bool --- 
	is_alive :: proc(world: ^World, entity: Entity) -> c.bool --- 
	strip_generation :: proc(entity: Entity) -> id ---
	get_alive :: proc(world: ^World, entity: Entity) -> Entity ---
	ensure :: proc(world: ^World, entity: Entity) ---
	ensure_id :: proc(world: ^World, id: id) ---
	exists :: proc(world: ^World, entity: Entity) -> c.bool ---
	get_type :: proc(world: ^World, entity: Entity) -> ^type ---
	get_table :: proc(world: ^World, entity: Entity) -> ^table ---
	get_storage_table :: proc(world: ^World, entity: Entity) -> ^table ---
	get_type_info :: proc(world: ^World, id: id) -> ^type_info ---
	get_typeid :: proc(world: ^World, id: id) -> Entity ---
	id_is_tag :: proc(world: ^World, id: id) -> Entity ---
	id_in_use :: proc(world: ^World, id: id) -> c.bool ---
	get_name :: proc(world: ^World, entity: Entity) -> cstring ---
	get_symbol :: proc(world: ^World, entity: Entity) -> cstring ---
	set_name :: proc(world: ^World, entity: Entity, name: cstring) -> Entity ---
	set_symbol:: proc(world: ^World, entity: Entity, symbol: cstring) -> Entity ---
	set_alias:: proc(world: ^World, entity: Entity, alias: cstring) ---
	id_flag_str :: proc(id_flags: id) -> cstring ---
	id_str :: proc(world: ^World, id: id) -> cstring ---
	id_str_buf :: proc(world: ^World, id: id, buf: ^Strbuf) ---
	type_str :: proc(world: ^World, _type: ^Type) -> cstring ---
	table_str :: proc(world: ^World, table: ^Table) -> cstring ---
	entity_str :: proc(world: ^World, entity: Entity) -> cstring ---
	has_id :: proc(world: ^World, entity: Entity, id: id) -> c.bool ---
	get_target :: proc(world: ^World, entity: Entity, rel: Entity, index: c.int32_t) -> Entity ---
	get_target_for_id :: proc(world: ^World, entity: Entity, id: id, index: c.int32_t) -> Entity ---
	enable :: proc(world: ^World, entity: Entity, enabled: c.bool) ---
	count_id :: proc(world: ^World, entity: Entity) -> c.int32_t ---
	lookup :: proc(world: ^World, name: cstring) -> Entity ---
	lookup_child :: proc(world: ^World, parent: Entity, name: cstring) -> Entity ---
	lookup_path_w_sep :: proc(world: ^World, parent: Entity, path: cstring, sep: cstring, prefix: cstring, recursive: c.bool) -> Entity ---
	lookup_symbol :: proc(world: ^World, symbol: cstring, lookup_as_path: c.bool) -> Entity ---
	// paths
	get_path_w_sep :: proc(world: ^World, parent: Entity, child: Entity, sep: cstring, prefix: cstring) -> cstring ---
	get_path_w_sep_buf :: proc(world: ^World, parent: Entity, child: Entity, sep: cstring, prefix: cstring, buf: ^Strbuf) ---
	new_from_path_w_sep :: proc(world: ^World, parent: Entity, path: cstring, sep: cstring, prefix: cstring) -> Entity ---
	add_path_w_sep :: proc(world: ^World, entity: Entity, parent: Entity, path: cstring, sep: cstring, prefix: cstring) -> Entity ---
	set_scope :: proc(world: ^World, scope: Entity) -> Entity ---
	get_scope :: proc(world: ^World) -> Entity ---
	set_with :: proc(world: ^World, id: id) -> Entity ---
	get_with :: proc(world: ^World) -> id ---
	set_name_prefix :: proc(world: ^World, prefix: cstring) -> cstring ---
	set_lookup_path :: proc(world: ^World, lookup_path: ^Entity) -> ^Entity ---
	get_lookup_path :: proc(world: ^World) -> ^Entity ---
	// terms
	term_iter :: proc(world: ^World, term: ^Term) -> Iter ---
	term_chain_iter :: proc(it: ^Iter, term: ^Term) -> Iter
	term_next :: proc(it: ^Iter) -> c.bool ---
	term_id_is_set :: proc(id: ^Term_Id) -> c.bool ---
	term_is_initialized :: proc(it: ^Term) -> c.bool ---
	term_match_this :: proc(it: ^Term) -> c.bool ---
	term_is_match_0 :: proc(it: ^Term) -> c.bool ---
	term_finalize :: proc(world: ^World, term: ^Term) -> c.int ---
	term_copy :: proc(src: ^Term) -> c.bool ---
	term_move :: proc(src: ^Term) -> Term ---
	term_fini ::proc(term: ^Term) ---
	id_match :: proc(id: id, pattern: id) --- 
	id_is_pair :: proc(id: id) -> c.bool ---
	id_is_wildcard :: proc(id: id) -> c.bool ---
	id_is_valid :: proc(world: ^World, id: id) -> c.bool ---
	id_get_flags :: proc(world: ^World, id: id) -> flags32 ---
	// filters
	filter_init :: proc(world: ^World, desc: ^Filter_Desc) -> Filter ---
	filter_fini :: proc(filter: ^Filter) ---
	filter_finalize :: proc(world: ^World, filter: ^Filter) -> c.int ---
	filter_find_this_var :: proc(filter: ^Filter) -> c.int32_t ---
	term_str :: proc(world: ^World, term: ^Term) -> cstring ---
	filter_str :: proc(world: ^World, filter: ^Filter) -> cstring ---
	filter_iter :: proc(world: ^World, filter: ^Filter) -> Iter ---
	filter_chain_iter :: proc(iter: ^Iter, filter: ^Filter) -> Iter ---
	filter_pivot_term :: proc(world: ^World, filter: ^Filter) -> c.int32_t ---
	filter_next :: proc(it: ^Iter) -> c.bool ---
	filter_next_instanced :: proc(it: ^Iter) -> c.bool ---
	filter_move :: proc(dst: ^Filter, src: ^Filter) ---
	filter_copy :: proc(dst: ^Filter, src: ^Filter) ---
	// queries
	query_init :: proc(world: ^World, desc: ^Query_Desc) -> Filter ---
	query_fini :: proc(filter: ^Filter) ---
	query_get_filter :: proc(query: ^Query) -> ^Filter ---
	query_iter :: proc(world: ^World, query: ^Query) -> Iter ---
	query_next :: proc(iter: ^Iter) -> c.bool ---
	query_next_instanced :: proc(iter: ^Iter) -> c.bool ---
	query_changed :: proc(query: ^Query, it: ^Iter) -> c.bool ---
	query_skip :: proc(it: ^Iter) ---
	query_set_group :: proc(it: ^Iter, group_id: c.uint64_t) ---
	query_orphaned :: proc(query: ^Query) -> c.bool ---
	query_str :: proc(query: ^Query) -> cstring ---
	query_table_count :: proc(query: ^Query) -> c.int32_t ---
	query_empty_table_count :: proc(query: ^Query) -> c.int32_t ---
	query_entity_count :: proc(query: ^Query) -> c.int32_t ---
	// observers
	emit :: proc(world: ^World, desc: ^Event_Desc) ---
	observer_init :: proc(world: ^World, desc: ^Observer_Desc) ---
	observer_default_run_action :: proc(it: ^Iter) -> c.bool ---
	get_observer_ctx :: proc(world: ^World, observer: Entity) -> rawptr ---
	get_observer_binding_ctx :: proc(world: ^World, observer: Entity) -> rawptr ---
	// iterators
	iter_poly :: proc(world: ^World, poly: Poly, iter: ^Iter, filter: ^Filter) -> rawptr ---
	iter_next :: proc(it: ^Iter) -> c.bool ---
	iter_fini :: proc(it: ^Iter) ---
	iter_count :: proc(it: ^Iter) -> c.int32_t ---
	iter_is_true :: proc(it: ^Iter) -> c.bool ---
	iter_set_var :: proc(it: ^Iter, var_id: c.int32_t, entity: Entity) ---
	iter_set_var_as_table :: proc(it: ^Iter, entity: Entity, table: ^Table) ---
	iter_set_var_as_range :: proc(it: ^Iter, entity: Entity, range: ^Table_Range) ---
	iter_get_var :: proc(it: ^Iter, var_id: c.int32_t) -> ^Entity ---
	iter_get_var_as_table :: proc(it: ^Iter, var_id: c.int32_t) -> ^Table ---
	iter_get_var_as_range :: proc(it: ^Iter, var_id: c.int32_t) -> ^Table_Range ---
	iter_var_is_constrained :: proc(it: ^Iter, var_id: c.int32_t) -> c.bool ---
	page_iter :: proc(it: ^Iter, offset: c.int32_t, limit: c.int32_t) -> Iter ---
	page_next :: proc(it: ^Iter) -> c.bool ---
	worker_iter :: proc(it: ^Iter, index: c.int32_t, count: c.int32_t) -> Iter ---
	worker_next :: proc(it: ^Iter) -> c.bool ---
	field_w_size :: proc(it: ^Iter, size: c.int32_t, index: c.int32_t) -> rawptr ---
	field_is_readonly :: proc(it: ^Iter, index: c.int32_t) -> c.bool ---
	field_is_writeonly :: proc(it: ^Iter, index: c.int32_t) -> c.bool ---
	field_is_set :: proc(it: ^Iter, index: c.int32_t) -> c.bool ---
	field_id :: proc(it: ^Iter, index: c.int32_t) -> Entity ---
	field_src :: proc(it: ^Iter, index: c.int32_t) -> Entity ---
	field_size :: proc(it: ^Iter, index: c.int32_t) -> c.size_t ---
	field_is_self :: proc(it: ^Iter, index: c.int32_t) -> c.bool ---
	iter_str :: proc(it: ^Iter) -> cstring ---
	iter_find_column :: proc(it: ^Iter, id: id) -> c.int32_t ---
	iter_column_w_size :: proc(it: ^Iter, size: c.int32_t, index: c.int32_t) -> c.size_t ---
	iter_column_size :: proc(it: ^Iter, index: c.int32_t) -> c.size_t ---
	// staging
	frame_begin :: proc(world: ^World, delta_time: ftime) -> ftime ---
	frame_end :: proc(world: ^World) ---
	readonly_begin :: proc(world: ^World) -> c.bool ---
	readonly_end :: proc(world: ^World) ---
	merge :: proc(world: ^World) ---
	defer_begin :: proc(world: ^World) -> c.bool ---
	is_deferred :: proc(world: ^World) -> c.bool ---
	defer_end :: proc(world: ^World) -> c.bool ---
	defer_suspend :: proc(world: ^World) ---
	defer_resume :: proc(world: ^World) ---
	set_automerge :: proc(world: ^World, automerge: c.bool) ---
	set_stage_count :: proc(world: ^World, stages: c.int32_t) ---
	get_stage_count :: proc(world: ^World) -> c.int32_t ---
	get_stage_id :: proc(world: ^World) -> c.int32_t ---
	get_stage :: proc(world: ^World, stage_id: c.int32_t) -> ^World ---
	get_world :: proc(world: Poly) -> ^World ---
	stage_is_readonly :: proc(world: ^World) -> c.bool ---
	async_stage_new :: proc(world: ^World) -> ^World ---
	async_stage_free :: proc(stage: ^World) ---
	stage_is_async :: proc(stage: ^World) -> c.bool ---
	search :: proc(world: ^World, table: ^Table, id: id, id_out: ^id) -> c.int32_t ---
	search_offset :: proc(world: ^World, table: ^Table, offset: c.int32_t, id: id, id_out: ^id) -> c.int32_t ---
	search_relation :: proc(
		world: ^World, 
		table: ^Table, 
		offset: c.int32_t, 
		id: id,
		rel: Entity,
		flags: flags32,
		subject_out: ^Entity,
		id_out: ^id,
		tr_out: ^^Table_Record,
	) -> c.int32_t ---
	table_get_type :: proc(table: ^Table) -> ^Type ---
	table_get_column :: proc(table: ^Table, index: c.int32_t) -> rawptr ---
	table_get_storage_table :: proc(table: ^Table) -> ^Table ---
	table_type_to_storage_index :: proc(table: ^Table) -> c.int32_t ---
	table_storage_to_type_index :: proc(table: ^Table, index: c.int32_t) -> c.int32_t ---
	table_count :: proc(table: ^Table) -> c.int32_t ---
	table_add_id :: proc(world: ^World, table: ^Table, id: id) -> ^Table ---
	table_remove_id :: proc(world: ^World, table: ^Table, id: id) -> ^Table ---
	table_lock :: proc(world: ^World, table: ^Table) ---
	table_unlock :: proc(world: ^World, table: ^Table) ---
	table_has_module :: proc(table: ^Table) -> c.bool ---
	table_swap_rows :: proc(world: ^World, table: ^Table, row_1: c.int32_t, row_2: c.int32_t) ---
	commit :: proc(world: ^World, entity: Entity, record: ^Record, table: ^Table, added: ^Type, removed: ^Type) -> c.bool ---
	record_find :: proc(world: ^World, entity: Entity) -> ^Record ---
	record_get_column :: proc(record: ^Record, column: c.int32_t, c_size: c.size_t) -> rawptr ---
}
