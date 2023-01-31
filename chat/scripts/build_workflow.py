from cloudify.state import workflow_ctx, workflow_parameters

chat_inst = next(inst
    for inst in workflow_ctx.node_instances
    if inst.node_id == 'chatapp'
)
target = workflow_parameters.get('target', '/opt/manager/resources/chat_1')
flags = workflow_parameters.get('flags', '')


graph = workflow_ctx.graph_mode()
seq = graph.sequence()
seq.add(
    chat_inst.execute_operation('cloudify.interfaces.lifecycle.create', kwargs={
        'FLAGS': flags,
    }, allow_kwargs_override=True),
    chat_inst.execute_operation('cloudify.interfaces.lifecycle.start', kwargs={
        'TARGET': target,
    }, allow_kwargs_override=True)
)
graph.execute()
