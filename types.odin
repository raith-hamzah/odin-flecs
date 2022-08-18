package flecs
import "core:c"

RULE_MAX_VAR_COUNT :: 32
TERM_CACHE_SIZE :: 4
RULE_PAIR_PREDICATE :: 1
RULE_PAIR_OBJECT :: 2
ID_CACHE_SIZE :: 32
STRBUF_ELEMENT_SIZE :: 511
STRBUF_MAX_LIST_DEPTH :: 32
OBSERVER_DESC_EVENT_COUNT_MAX :: 8

// api types
Poly :: rawptr
size :: c.int32_t
id :: c.uint64_t
Entity :: id
map_key :: c.uint64_t

// primitive types
float :: c.float
ftime :: float

// bitmask types
flags8 :: c.uint8_t
flags16 :: c.uint16_t
flags32 :: c.uint32_t
flags64 :: c.uint64_t

// handle types
os_thread: c.uintptr_t
os_cond: c.uintptr_t
os_mutex: c.uintptr_t
os_dl: c.uintptr_t
os_sock: c.uintptr_t

// OS API
os_proc :: #type proc "c" ()
// inits
os_api_init :: #type proc "c" ()
os_api_fini :: #type proc "c" ()
// memory
os_api_malloc :: #type proc "c" (size: size) -> rawptr
os_api_free :: #type proc "c" (ptr: rawptr)
os_api_realloc :: #type proc "c" (ptr: rawptr) -> rawptr
os_api_calloc :: #type proc "c" (size: size) -> rawptr
os_api_strdup :: #type proc "c" (str: ^c.char) -> cstring
// threads
os_thread_callback :: #type proc "c" (_: rawptr) -> rawptr
os_api_thread_new :: #type proc "c" (callback: os_thread_callback) -> os_thread
os_api_thread_join :: #type proc "c" (thread: os_thread) -> rawptr
os_api_ainc :: #type proc "c" (value: ^c.int32_t) -> c.int
// mutex
os_api_mutex_new :: #type proc "c" () -> os_mutex
os_api_mutex_lock :: #type proc "c" (mutex: os_mutex)
os_api_mutex_unlock :: #type proc "c" (mutex: os_mutex)
os_api_mutex_free :: #type proc "c" (mutex: os_mutex)
// condition variable
os_api_cond_new :: #type proc "c" () -> os_cond
os_api_cond_free :: #type proc "c" (cond: os_cond)
os_api_cond_signal :: #type proc "c" (cond: os_cond)
os_api_cond_broadcast :: #type proc "c" (cond: os_cond)
os_api_cond_wait :: #type proc "c" (cond: os_cond, mutex: os_mutex)
os_api_sleep :: #type proc "c" (sec: c.int32_t, nanosec: c.int32_t)
os_api_enable_high_timer_resolution :: #type proc "c" (enable: c.bool)
os_api_get_time :: #type proc "c" (time_out: Time)
os_api_now :: #type proc "c" () -> c.uint64_t
// logging
os_api_log :: #type proc "c" (level: c.int32_t, file: cstring, line: c.int32_t, msg: cstring)
os_api_abort :: #type proc "c" ()
// dynamic libraries
os_api_dlopen :: #type proc "c" (libname: cstring) -> os_dl
os_api_dlproc :: #type proc "c" (lib: os_dl, procname: cstring) -> os_proc

Os_Api :: struct {
	// api init
	init_:             os_api_init,
	fini_:             os_api_fini,
	// memory
	malloc_:           os_api_malloc,
	realloc_:          os_api_realloc,
	calloc_:           os_api_calloc,
	free_:             os_api_free,
	// strings
	strdup_:           os_api_strdup,
	// atomic
	ainc_:             os_api_ainc,
	adec_:             os_api_ainc,
	// mutex
	mutex_new_:        os_api_mutex_new,
	mutex_free_:       os_api_mutex_free,
	mutex_lock_:       os_api_mutex_lock,
	mutex_unlock_:     os_api_mutex_lock,
	// condition variables
	cond_new_:         os_api_cond_new,
	cond_free_:        os_api_cond_free,
	cond_signal_:      os_api_cond_signal,
	cond_broadcast_:   os_api_cond_broadcast,
	cond_wait_:        os_api_cond_wait,
	// time 
	sleep_:            os_api_sleep,
	now_:              os_api_now,
	getime_:           os_api_getime,
	// logging
	log_:              os_api_log,
	abort_:            os_api_abort,
	// dynaminc library loading
	dlopen_:           os_api_dlopen,
	dlproc_:           os_api_dlproc,
	dlclose_:          os_api_dlclose,
	moduleo_dl_:       os_api_moduleo_path,
	// trace 
	log_level_:        c.int32_t,
	log_indent_:       c.int32_t,
	log_last_error_:   c.int32_t,
	log_lastimestamp_: c.int32_t,
	// OS API flags
	flags_:            flags32,
}

Type :: struct {
	array: [^]id,
	count: c.int32_t,
}

Mixin_Kind :: enum c.int {
	EcsMixinWorld      = 0,
	EcsMixinEntity     = 1,
	EcsMixinObservable = 2,
	EcsMixinIterable   = 3,
	EcsMixinDtor       = 4,
	EcsMixinBase       = 5,
	EcsMixinMax        = 6,
}

Time :: struct {
	sec:     c.uint32_t,
	nanosec: c.uint32_t,
}

Mixins :: struct {
	type_name: cstring,
	elems:     [EcsMixinMax]size,
}

Header :: struct {
	magic:  c.int32_t,
	_type:  c.int32_t,
	mixins: ^Mixins,
}


Bucket_Entry :: struct {
	next: ^Bucket_Entry,
	key:  map_key,
}

Block_Allocator_Block :: struct {
	memory: rawptr,
	next:   ^Block_Allocator_Block,
}

Block_Allocator_Chunk_Header :: struct {
	next: ^Block_Allocator_Chunk_Header,
}

Block_Allocator :: struct {
	head:             ^Block_Allocator_Chunk_Header,
	block_head:       ^Block_Allocator_Block,
	blockail:         ^Block_Allocator_Block,
	chunk_size:       c.int32_t,
	chunks_per_block: c.int32_t,
	block_size:       c.int32_t,
}

Bucket :: struct {
	first: ^Bucket_Entry,
}

Map :: struct {
	buckets:      [^]Bucket,
	buckets_end:  ^Bucket,
	elem_size:    c.int16_t,
	bucket_shift: c.uint8_t,
	bucket_count: c.int32_t,
	count:        c.int32_t,
	allocator:    Block_Allocator,
}

Map_Iter :: struct {
	_map:   ^Map,
	bucket: ^Bucket,
	entry:  ^Bucket_Entry,
}

Vector :: struct {
	count: c.int32_t,
	size:  c.int32_t,
}

Sparse :: struct {
	dense:        ^Vector,
	chunks:       ^Vector,
	size:         size,
	count:        c.int32_t,
	max_id_local: c.uint64_t,
	max_id:       ^c.uint64_t,
}

Table_Cache_Hdr :: struct {
	cache: ^Table_Cache,
	table: ^Table,
	prev:  ^Table_Cache_Hdr,
	empty: c.bool,
}

Table_Diff :: struct {
	added:   Type,
	removed: Type,
	on_set:  Type,
	un_set:  Type,
}

Bitset :: struct {
	data:  ^c.uint64_t,
	count: c.int32_t,
	size:  size,
}

Switch :: struct {
	headers: Map,
	nodes:   ^Vector,
	values:  ^Vector,
}

Column :: struct {
	array: rawptr,
	count: c.int32_t,
	size:  c.int32_t,
}

Data :: struct {
	entities:   Column,
	records:    Column,
	columns:    [^]Column,
	sw_columns: ^Switch,
	bs_columns: ^Bitset,
}

Graph_Edge_Hdr :: struct {
	prev: ^graph_Edge_Hdr,
	next: ^graph_Edge_Hdr,
}

Graph_Edge :: struct {
	hdr:  Graph_Edge_Hdr,
	from: ^Table,
	to:   ^Table,
	diff: ^Table_Diff,
	id:   id,
}

Graph_Edges :: struct {
	lo: ^graph_edge,
	hi: Map,
}

Graph_Node :: struct {
	add:    Graph_Edges,
	remove: Graph_Edges,
	refs:   Graph_Edge_Hdr,
}

Iter_Kind :: enum c.int {
	EcsIterEvalCondition = 0,
	EcsIterEvalTables    = 1,
	EcsIterEvalChain     = 2,
	EcsIterEvalNone      = 3,
}

Record :: struct {
	table: ^Table,
	row:   c.uint32_t,
}

Table_Range :: struct {
	table:  ^Table,
	offset: c.int32_t,
	count:  c.int32_t,
}

Var :: struct {
	range:  Table_Range,
	entity: Entity,
}


Ref :: struct {
	entity: Entity,
	id:     Entity,
	tr:     ^Table_Record,
	record: record,
}

Page_Iter :: struct {
	offset:    c.int32_t,
	limit:     c.int32_t,
	remaining: c.int32_t,
}

Table_Cache_Iter :: struct {
	cur:       ^Table_Cache_Hdr,
	next:      ^Table_Cache_Hdr,
	next_list: ^Table_Cache_Hdr,
}

Term_Iter :: struct {
	term:         term,
	self_index:   ^Id_Record,
	set_index:    ^Id_Record,
	cur:          ^Id_Record,
	it:           Table_Cache_Iter,
	index:        c.int32_t,
	table:        ^Table,
	cur_match:    c.int32_t,
	match_count:  c.int32_t,
	last_column:  c.int32_t,
	empty_tables: c.bool,
	id:           id,
	column:       c.int32_t,
	subject:      Entity,
	size:         size,
	ptr:          rawptr,
}

xtor :: #type proc "c" (ptr: rawptr, count: c.int32_t, type_info: ^Type_Info)
copy :: #type proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: c.int32_t, type_info: ^Type_Info)
move :: #type proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: c.int32_t, type_info: ^Type_Info)

Type_Hooks :: struct {
	ctor:             xtor,
	dtor:             xtor,
	copy:             copy,
	move:             move,
	copy_ctor:        copy,
	move_ctor:        move,
	ctor_move_dtor:   move,
	ctor_move_dtor:   move,
	on_add:           iter_action,
	on_set:           iter_action,
	on_remove:        iter_action,
	ctx:              rawptr,
	binding_ctx:      rawptr,
	ctx_free:         ctx_free,
	binding_ctx_free: ctx_free,
}

Type_Info :: struct {
	size:      size,
	alignment: size,
	hooks:     Type_Hooks,
	component: Entity,
}

Table :: struct {
	id:                            c.uint64_t,
	_type:                         Type,
	flags, flags32, storage_count: c.uint16_t,
	generation:                    c.uint16_t,
	records:                       [^]table_record,
	storage_table:                 ^Table,
	storage_ids:                   [^]id,
	storage_map:                   ^c.int32_t,
	node:                          Graph_Node,
	data:                          Data,
	type_info:                     ^Type_Info,
	dirty_States:                  ^c.int32_t,
	sw_count:                      c.int16_t,
	sw_offset:                     c.int16_t,
	bs_count:                      c.int16_t,
	bs_offset:                     c.int16_t,
	refcount:                      c.int32_t,
	lock:                          c.int32_t,
	record_count:                  c.uint16_t,
}

Table_Cache_List :: struct {
	first: ^Table_Cache_Hdr,
	last:  ^Table_Cache_Hdr,
	count: c.int32_t,
}

Table_Cache :: struct {
	index:        Map,
	tables:       Table_Cache_List,
	empty_tables: Table_Cache_List,
}

Id_Record_Elem :: struct {
	prev: ^Id_Record,
	next: ^Id_Record,
}

ctx_free :: #type proc "c" (ctx: rawptr)
hash_value_action :: #type proc "c" (ptr: rawptr) -> c.uint64_t
compare_action :: #type proc "c" (ptr: rawptr) -> c.int

Hashmap :: struct {
	hash:       hash_value_action,
	compare:    compare_action,
	key_size:   size,
	value_size: size,
	impl:       Map,
}

Hashmap_Iter :: struct {
	it:     Map_Iter,
	bucket: ^hm_bucket,
	index:  c.int32_t,
}

Hashmap_Result :: struct {
	key:   rawptr,
	value: rawptr,
	hash:  c.uint64_t,
}

Id_Record :: struct {
	cache:      Table_Cache,
	flags:      flags32,
	refcount:   c.int32_t,
	name_index: ^hashmap,
	type_info:  ^Type_Info,
	id:         id,
	parent:     ^Id_Record,
	first:      Id_Record_Elem,
	second:     Id_Record_Elem,
	acyclic:    Id_Record_Elem,
}

Inout_Kind :: enum c.int {
	EcsInOutDefault = 0,
	EcsInOutNone    = 1,
	EcsInOut        = 2,
	EcsIn           = 3,
	EcsOut          = 4,
}

Oper_Kind :: enum c.int {
	EcsAnd      = 0,
	EcsOr       = 1,
	EcsNot      = 2,
	EcsOptional = 3,
	EcsAndFrom  = 4,
	EcsOrFrom   = 5,
	EcsNotFrom  = 6,
}

Term_Id :: struct {
	id:    Entity,
	name:  cstring,
	trav:  Entity,
	flags: flags32,
}

Term :: struct {
	id:          id,
	src:         Term_Id,
	first:       Term_Id,
	second:      Term_Id,
	inout:       Inout_Kind,
	oper:        Oper_Kind,
	id_flags:    id,
	name:        cstring,
	field_index: c.int32_t,
	move:        c.bool,
}

Monitor_Set :: struct {
	monitors: Map,
	is_dirty: c.bool,
}

Observable :: struct {
	events: [^]Sparse,
}

Stack_Page :: struct {
	data: rawptr,
	next: ^Stack_Page,
	sp:   size,
}

Stack :: struct {
	first: Stack_page,
	cur:   ^Stack_page,
}

Stage :: struct {
	hdr:                Header,
	id:                 c.int32_t,
	_defer:             c.int32_t,
	defer_queue:        ^Vector,
	defer_stack:        ^Stack,
	defer_suspend:      c.bool,
	thread_ctx:         ^World,
	world:              ^World,
	thread:             os_thread,
	post_frame_actions: [^]Vector,
	scope:              Entity,
	with:               Entity,
	base:               Entity,
	lookup_path:        ^Entity,
	auto_merge:         c.bool,
	async:              c.bool,
}

World_Info :: struct {
	last_component_id:          Entity,
	last_id:                    Entity,
	min_id:                     Entity,
	max_id:                     Entity,
	delta_time_raw:             ftime,
	delta_time:                 ftime,
	time_scale:                 ftime,
	target_fps:                 ftime,
	frame_time_total:           ftime,
	system_time_total:          c.float,
	merge_time_total:           c.float,
	world_time_Total:           ftime,
	world_time_total_raw:       ftime,
	frame_count_total:          c.int32_t,
	merge_count_total:          c.int32_t,
	id_create_total:            c.int32_t,
	id_delete_total:            c.int32_t,
	table_create_total:         c.int32_t,
	table_delete_total:         c.int32_t,
	pipeline_build_count_total: c.int32_t,
	systems_ran_frame:          c.int32_t,
	id_count:                   c.int32_t,
	tag_id_count:               c.int32_t,
	component_id_count:         c.int32_t,
	pair_id_count:              c.int32_t,
	wildcard_id_count:          c.int32_t,
	table_count:                c.int32_t,
	tagable_count:              c.int32_t,
	trivial_table_count:        c.int32_t,
	empty_table_count:          c.int32_t,
	table_record_count:         c.int32_t,
	table_storage_count:        c.int32_t,
	new_count:                  c.int32_t,
	bulk_new_count:             c.int32_t,
	delete_count:               c.int32_t,
	clear_count:                c.int32_t,
	add_count:                  c.int32_t,
	remove_count:               c.int32_t,
	set_count:                  c.int32_t,
	discard_count:              c.int32_t,
}

iter_action :: #type proc "c" (it: ^iter)
run_action :: #type proc "c" (it: ^iter)
iter_next_action :: #type proc "c" (it: ^iter)
iter_init_action :: #type proc "c" (world: ^World, iterable: Poly, it: ^iter, filter: ^term)
iter_fini_action :: #type proc "c" (it: ^iter)
order_by_action :: #type proc "c" (e1: Entity, ptr1: rawptr, e2: Entity, ptr2: rawptr)
sortable_action :: #type proc "c" (
	world: ^World,
	table: ^Table,
	entities: [^]entity,
	ptr: rawptr,
	size: c.int32_t,
	lo: c.int32_t,
	hi: c.int32_t,
	order_by: order_by_action,
)
group_by_action :: #type proc "c" (world: ^World, table: ^Table, group_id: id, ctx: rawptr)
module_action :: #type proc "c" (world: ^World)


Iterable :: struct {
	init: Iter_Init_Action,
}

Iter_Cache :: struct {
	ids:           [TERM_CACHE]id,
	columns:       [TERM_CACHE]c.int32_t,
	sources:       [TERM_CACHE]Entity,
	sizes:         [TERM_CACHE]Size,
	ptrs:          [TERM_CACHE]rawptr,
	match_indices: [TERM_CACHE]c.int32_t,
	variables:     [TERM_CACHE]Var,
	used:          flags8,
	allocated:     flags8,
}

Iter_Private :: struct {
	iter:  struct #raw_union {
		term:     Term_Iter,
		filter:   Filter_Iter,
		query:    Query_Iter,
		rule:     Rule_Iter,
		snapshot: Snapshot_Iter,
		page:     Page_Iter,
		worker:   Qorker_Iter,
	},
	cache: Iter_Cache,
}

Iter :: struct {
	// world
	world:             ^World,
	real_world:        ^World,

	// matched data
	entities:          [^]Entity,
	ptrs:              [^]rawptr,
	sizes:             [^]Size,
	table:             ^Table,
	other_table:       ^Table,
	ids:               [^]id,
	variables:         [^]Var,
	columns:           ^c.int32_t,
	sources:           [^]Entity,
	match_indices:     [^]c.int32_t,
	references:        [^]Ref,
	constrained_vars:  flags64,
	group_id:          c.uint64_t,
	field_count:       c.int32_t,

	// input info
	system:            Entity,
	event:             Entity,
	event_id:          id,

	// query info
	terms:             ^Term,
	table_count:       c.int32_t,
	term_index:        c.int32_t,
	variable_count:    c.int32_t,
	variable_names:    [^]cstring,
	/* Context */
	param:             rawptr,
	ctx:               rawptr,
	binding_ctx:       rawptr,
	/* Time */
	delta_time:        ftime,
	delta_system_time: ftime,
	/* Iterator counters */
	frame_offset:      c.int32_t,
	offset:            c.int32_t,
	count:             c.int32_t,
	instance_count:    c.int32_t,
	/* Iterator flags */
	flags:             flags32,
	interrupted_by:    Entity,
	priv:              Iter_Private,
	/* Chained iterators */
	next:              iter_next_action,
	callback:          iter_action,
	fini:              iter_fini_action,
	chain_it:          ^Iter,
}

World :: struct {
	hdr:                   Header,

	// metadata
	id_index:              Map,
	type_info:             ^Sparse,

	// cached handle to id records
	idr_wildcard:          ^Id_Record,
	idr_wildcard_wildcard: ^Id_Record,
	idr_any:               ^Id_Record,
	idr_isa_wildcard:      ^Id_Record,
	idr_childof_0:         ^Id_Record,
	idr_wildcard:          ^Id_Record,

	// mixins
	self:                  ^World,
	observable:            Observable,
	iterable:              Iterable,

	// uniqe id generated per event
	event_id:              c.int32_t,

	// is range checking enabled
	range_check_enabled:   c.bool,

	// data storage
	store:                 Store,

	// pending table event buffers
	pending_buffer:        ^Sparse,
	pending_tables:        ^Sparse,

	// Used to track when cache needs to be updated 
	monitors:              Monitor_Set,

	// systems
	pipeline:              Entity,

	// identifiers
	aliases:               Hashmap,
	symbols:               Hashmap,
	name_prefix:           cstring,

	// staging
	stages:                [^]Stage,
	stage_count:           c.int32_t,

	// multithreading
	worker_cond:           os_cond,
	sync_cond:             os_cond,
	sync_mutex:            os_mutex,
	workers_running:       c.int32_t,
	workers_waiting:       c.int32_t,

	// time management
	world_start_time:      Time,
	frame_start_time:      Time,
	fps_sleep:             ftime,

	// metrics
	info:                  ^World_Info,

	// world flags
	flags:                 flags32,
	_context:              rawptr,
	fini_actions:          [^]Vector,
}

Filter :: struct {
	hdr:            Header,
	terms:          [^]term,
	term_count:     c.int32_t,
	field_count:    c.int32_t,
	owned:          c.bool,
	terms_owned:    c.bool,
	flags:          flags32,
	name:           cstring,
	variable_names: [1]cstring,
	iterable:       Iterable,
}

Rule_Var_Kind :: enum c.int {
	EcsRuleVarKindTable   = 0,
	EcsRuleVarKindEntity  = 1,
	EcsRuleVarKindUnknown = 2,
}

Rule_Op_Kind :: enum c.int {
	EcsRuleInput    = 0,
	EcsRuleSelect   = 1,
	EcsRuleWith     = 2,
	EcsRuleSubSet   = 3,
	EcsRuleSuperSet = 4,
	EcsRuleStore    = 5,
	EcsRuleEach     = 6,
	EcsRuleSetJmp   = 7,
	EcsRuleJump     = 8,
	EcsRuleNot      = 9,
	EcsRuleInTable  = 10,
	EcsRuleEq       = 11,
	EcsRuleYield    = 12,
}

Rule_Var :: struct {
	kind:   Rule_Var_Kind,
	name:   cstring,
	id:     c.int32_t,
	other:  c.int32_t,
	occurs: c.int32_t,
	depth:  c.int32_t,
	marked: c.bool,
}

Rule_Term_Vars :: struct {
	first:  c.int32_t,
	src:    c.int32_t,
	second: c.int32_t,
}

Rule_Pair :: struct {
	first:      struct #raw_union {
		reg: c.int32_t,
		id:  Entity,
	},
	second:     struct #raw_union {
		reg: c.int32_t,
		id:  Entity,
	},
	reg_mask:   c.int32_t,
	transitive: c.bool,
	final:      c.bool,
	reflexive:  c.bool,
	acyclic:    c.bool,
	second_0:   c.bool,
}

Rule_Op :: struct {
	kind:    Rule_Op_Kind,
	filter:  Rule_Pair,
	subject: Entity,
	on_pass: c.int32_t,
	on_fail: c.int32_t,
	frame:   c.int32_t,
	term:    c.int32_t,
	r_in:    c.int32_t,
	r_out:   c.int32_t,
	has_in:  c.bool,
	has_out: c.bool,
}

Rule :: struct {
	hdr:             Header,
	world:           ^World,
	operations:      [^]Rule_Op,
	filter:          Filter,
	vars:            [RULE_MAX_VAR_COUNT]Rule_Var,
	var_names:       [RULE_MAX_VAR_COUNT]cstring,
	term_vars:       [RULE_MAX_VAR_COUNT]Rule_Term_Vars,
	var_eval_order:  [RULE_MAX_VAR_COUNT]c.int32_t,
	var_count:       c.int32_t,
	subj_var_count:  c.int32_t,
	frame_count:     c.int32_t,
	operation_count: c.int32_t,
	iterable:        Iterable,
}

Entity_Desc :: struct {
	_canary:    c.int32_t,
	id:         Entity,
	name:       cstring,
	sep:        cstring,
	root_sep:   cstring,
	symbol:     cstring,
	use_low_id: c.bool,
	add:        [ID_CACHE_SIZE]id,
	add_expr:   cstring,
}

Bulk_Desc :: struct {
	_canary:  c.int32_t,
	entities: [^]Entity,
	count:    c.int32_t,
	ids:      [ID_CACHE_SIZE]id,
	data:     [^]rawptr,
	table:    ^Table,
}

Component_Desc :: struct {
	_canary: c.int32_t,
	entity:  Entity,
	_type:   Type_Info,
}

Strbuf_Element :: struct {
	buffer_embedded: c.bool,
	pos:             c.int32_t,
	buf:             cstring,
	next:            ^Strbuf_Element,
}

Strbuf_Element_Embedded :: struct {
	super: Strbuf_Element,
	buf:   [STRBUF_ELEMENT_SIZE + 1]c.char,
}

Strbuf_List_Elem :: struct {
	count:     c.int32_t,
	separator: cstring,
}

Strbuf :: struct {
	buf:           cstring,
	max:           c.int32_t,
	size:          c.int32_t,
	element_count: c.int32_t,
	first_element: Strbuf_Element_Embedded,
	current:       ^Strbuf_Element,
	list_stack:    [STRBUF_MAX_LIST_DEPTH]Strbuf_List_Elem,
	list_sp:       c.int32_t,
	content:       cstring,
	length:        c.int32_t,
}

Filter_Desc :: struct {
	_canary: c.int32_t,
	terms: [TERM_DESC_CACHE_SIZE]Term,
	terms_buffer: [^]Term,
	terms_buffer_count: c.int32_t,
	storage: ^Filter,
	instanced: c.bool,
	flags: flags32,
	expr: cstring,
}

Query_Table_Match :: struct {
	node: Query_Table_Node,
	table: ^Table,
	columns: [^]c.int32_t,
	ids: [^]id,
	sources: [^]Entity,
	sizes: [^]size,
	references: [^]Ref,
	sparse_columns: [^]Vector,
	bitset_columns: [^]Vector,
	group_id: c.uint64_t,
	next_match: ^Query_Table_Match,
	monitor: ^c.int32_t,
}

Query_Table_Node :: struct {
	match: ^Query_Table_Match,
	offset: c.int32_t,
	count: c.int32_t,
	prev, next: ^Query_Table_Node,
}

Query_Table_List :: struct {
	first: ^Query_Table_Node,
	last: ^Query_Table_Node,
	count: c.int32_t,
}

Query :: struct {
    hdr: Header,
    filter: Filter,
    cache: Table_Cache,
    list: Query_Table_List,
    groups: Map,
    order_by_component: Entity,
    order_by: order_by_action,
    sort_table: sort_table_action,
    table_slices: [^]Vector,
    group_by_id: Entity,
    group_by: group_by_action,
    group_by_ctx: rawptr,
    group_by_ctx_free: ctx_free,
    parent: ^Query,
    subqueries: [^]Vector,
    flags: flags32,
    cascade_by: c.int32_t,      
    match_count: c.int32_t,     
    prev_match_count: c.int32_t,
    rematch_count: c.int32_t,   
    world: ^World,
    iterable: ^Iterable,
    dtor: poly_dtor,
    entity: Entity,
}

Query_Desc :: struct {
	_canary: c.int32_t,
	filter: Filter_Desc,
	order_by_component: Entity,
	order_by: order_by_action,
	sort_table, sort_table_action,
	group_by_id: id,
	group_by: group_by_action,
	group_by_ctx: rawptr, 
	group_by_ctx_free: ctx_free,
	parent: ^Query,
	entity: Entity,
}

Event_Desc :: struct {
	event: Entity,
	ids: [^]Type,
	table: ^Table,
	other_table: ^Table,
	offset: c.int32_t,
	count: c.int32_t,
	param: rawptr,
	observable: Poly,
	table_event: c.bool,
	relationship: Entity,
}

Observer :: struct {
	hdr: Header,
	filter: Filter,
	events: [OBSERVER_DESC_EVENT_COUNT_MAX]Entity,
	event_count: c.int32_t,
	callback: iter_action,
	run: run_action,
	ctx: rawptr,
	binding_ctx: rawptr,
	ctx_free: ctx_free,
	binding_ctx_free: ctx_free,
	observable: ^Observable,
	last_event_id: ^c.int32_t,
	register_id: id,
	term_index: c.int32_t,
	is_monitor: c.bool,
	is_multi: c.bool,
	world: ^World,
	entity: Entity,
	dtor: poly_dtor,
}

Observer_Desc :: struct {
	_canary: c.int32_t,
	entity: Entity,
	filter: Filter_Desc,
	events: [OBSERVER_DESC_EVENT_COUNT_MAX]Entity,
	yield_existing: c.bool,
	callback: iter_action,
	run: run_action,
	ctx: rawptr,
	binding_ctx: rawptr,
	ctx_free: ctx_free,
}