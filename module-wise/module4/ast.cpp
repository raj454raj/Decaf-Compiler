#include "ast.h"
using namespace llvm;

static Type *typeOf(string type) {
    if (type == "integer" || type == "int") {
        return Type::getInt32Ty(getGlobalContext());
    }
    else if (type == "boolean" || type == "bool") {
        return Type::getInt1Ty(getGlobalContext());
    }
    else if (type == "character" || type == "char") {
        return Type::getInt8Ty(getGlobalContext());
    }
    else {
        return Type::getVoidTy(getGlobalContext());
    }
}

static Value *ref(Value* v, Node *n, CodeGenContext &context) {
    if(n->class_type == "location") {
        return context.load(v, ((Location *)n)->getVarName().c_str());
    }
    else {
        return v;
    }
}

Value *codeGenChildren(list<Node *> &children, CodeGenContext &context) {
    Value *ret;
    list <Node *>::iterator it;
    for(it = children.begin(); it != children.end() ; it++) {
        ret = (*it)->codeGen(context);
    }
    return ret;
}

void CodeGenContext::generateCode(Node* root) {
    root->codeGen(*this);
}

Value* Program::codeGen(CodeGenContext &context) {

    if(left)
    {
        list<Node*> fdecl = ((FieldDeclarations *)left)->ds;
        list<Node*>::iterator it;
        for(it=fdecl.begin();it != fdecl.end();it++)
        {
            if ((*it)->class_type == "field_declarations") {
                list<Node*> ofdecl = ((FieldDeclarations *)(*it))->ds;
                list<Node*>::iterator it2;
                for(it2=ofdecl.begin(); it2 != ofdecl.end(); it2++) {
                    if(((FieldDeclaration *)(*it2))->flag != "normal")
                    {
                        ArrayType* arrType = ArrayType::get(typeOf(((FieldDeclaration *)(*it2))->decl_type), ((FieldDeclaration *)(*it2))->size);
                        PointerType* ptrType = PointerType::get(arrType, 0);
                        GlobalVariable* gvar_ptr =
                            new GlobalVariable(*context.module,
                                    arrType,
                                    false,
                                    GlobalValue::ExternalLinkage,
                                    0,
                                    ((FieldDeclaration *)(*it2))->var_name
                                    );
                        gvar_ptr->setInitializer(ConstantAggregateZero::get(arrType));
                    }
                    else
                    {
                        PointerType* ptrType = PointerType::get(typeOf(((FieldDeclaration *)(*it2))->decl_type),0);
                        GlobalVariable* gvar_ptr =
                            new GlobalVariable(*context.module,
                                    typeOf(((FieldDeclaration *)(*it2))->decl_type),
                                    false,
                                    GlobalValue::ExternalLinkage,
                                    0,
                                    ((FieldDeclaration *)(*it2))->var_name
                                    );
                        gvar_ptr->setInitializer(ConstantAggregateZero::get(typeOf(((FieldDeclaration *)(*it2))->decl_type)));
                    }

                }
            }
            else {
                if(((FieldDeclaration *)(*it))->flag != "normal")
                {
                    ArrayType* arrType = ArrayType::get(typeOf(((FieldDeclaration *)(*it))->decl_type), ((FieldDeclaration *)(*it))->size);
                    PointerType* ptrType = PointerType::get(arrType, 0);
                    GlobalVariable* gvar_ptr =
                        new GlobalVariable(*context.module,
                                arrType,
                                false,
                                GlobalValue::ExternalLinkage,
                                0,
                                ((FieldDeclaration *)(*it))->var_name
                                );
                    gvar_ptr->setInitializer(ConstantAggregateZero::get(arrType));
                }
                else
                {
                    PointerType* ptrType = PointerType::get(typeOf(((FieldDeclaration *)(*it))->decl_type),0);
                    GlobalVariable* gvar_ptr =
                        new GlobalVariable(*context.module,
                                typeOf(((FieldDeclaration *)(*it))->decl_type),
                                false,
                                GlobalValue::ExternalLinkage,
                                0,
                                ((FieldDeclaration *)(*it))->var_name
                                );
                    gvar_ptr->setInitializer(ConstantAggregateZero::get(typeOf(((FieldDeclaration *)(*it))->decl_type)));
                }
            }
        }
    }
    Value *ret = NULL;
    if (right) {
        ret = right->codeGen(context);
    }
    return ret;
}

Value* FieldDeclarations::codeGen(CodeGenContext &context) {
    Value *ret = codeGenChildren(ds, context);
    return ret;
}

Value* FieldDeclaration::codeGen(CodeGenContext &context) {
    Value *alloc;
    if(flag == "normal") {
        alloc = Builder.CreateAlloca(typeOf(decl_type),
                NULL,
                var_name.c_str());
    }
    else {
        Value *sz = ConstantInt::get(typeOf("integer"),
                size,
                true);
        alloc = Builder.CreateAlloca(typeOf(decl_type),
                sz,
                var_name.c_str());
    }
    context.locals()[var_name] = alloc;
    return alloc;
}

Value* Assignment::codeGen(CodeGenContext &context) {
    Value *l, *r;
    l = left->codeGen(context);
    r = ref(right->codeGen(context), right, context);
    if(!l || !r) {
        return NULL;
    }
    return (new StoreInst(r, l, context.currentBlock()));
}

Value* Location::codeGen(CodeGenContext &context) {

    if(flag == "normal") {
        return context.getVar(var_name);
    }
    Value *pos = ref(exp->codeGen(context), exp, context);
    if(!pos) {
        return NULL;
    }
    vector<Value*> array_index;
    array_index.push_back(ConstantInt::get(typeOf("integer"), 0, true));
    array_index.push_back(pos);
    if(context.module->getGlobalVariable(var_name))
        return ConstantExpr::getGetElementPtr(context.module->getGlobalVariable(var_name),
                                              array_index);
    return Builder.CreateGEP(context.getVar(var_name), pos, var_name.c_str());
}

Value* FORStatement::codeGen(CodeGenContext &context) {

    assignment->codeGen(context);
    Function *func = Builder.GetInsertBlock()->getParent();
    BasicBlock *forLoop = BasicBlock::Create(getGlobalContext(), "loop");
    BasicBlock *forCond = BasicBlock::Create(getGlobalContext(), "cond");
    BasicBlock *forEnd = BasicBlock::Create(getGlobalContext(), "end");

    Builder.CreateBr(forCond);
    func->getBasicBlockList().push_back(forCond);
    Builder.SetInsertPoint(forCond);

    context.pushBlock(forCond);
    Value *cond = ref(end->codeGen(context), end, context);
    Value *condVal = Builder.CreateICmpNE(cond, ConstantInt::get(cond->getType(), 0), "loopcond");
    Builder.CreateCondBr(condVal, forLoop, forEnd);
    context.popBlock();

    forCond = Builder.GetInsertBlock();

    func->getBasicBlockList().push_back(forLoop);
    Builder.SetInsertPoint(forLoop);
    context.pushBlock(forLoop);
    Value *loop = body->codeGen(context);
    Builder.CreateBr(forCond);
    context.popBlock();
    forLoop = Builder.GetInsertBlock();
    func->getBasicBlockList().push_back(forEnd);
    Builder.SetInsertPoint(forEnd);
    context.pushBlock(forEnd);
    return NULL;
}

Value* Literal::codeGen(CodeGenContext &context) {
    if (type == "integer") {
        return ConstantInt::get(typeOf("integer"), stoi(val), true);
    }
    else if (type == "boolean") {
        return ConstantInt::get(typeOf("boolean"), val == "true", true);
    }
    else if (type == "character") {
        return ConstantInt::get(typeOf("character"), val[0], false);
    }
    else {
        return Builder.CreateGlobalStringPtr(val.c_str());
    }
}

Value* BinaryOp::codeGen(CodeGenContext &context) {

    Instruction::BinaryOps instr;
    Value *l = ref(lrand->codeGen(context), lrand, context);
    Value *r = ref(rrand->codeGen(context), rrand, context);
    if(!l || !r)
        return NULL;
    if (op == "addition") {
        instr = Instruction::Add;
    }
    else if (op == "subtraction") {
        instr = Instruction::Sub;
    }
    else if (op == "multiplication") {
        instr = Instruction::Mul;
    }
    else if (op == "division") {
        instr = Instruction::SDiv;
    }
    else if (op == "remainder") {
        instr = Instruction::SRem;
    }
    else if (op == "and") {
        instr = Instruction::And;
    }
    else if (op == "or") {
        instr = Instruction::Or;
    }
    else {
        if (op == "less_equal") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_ULE,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else if (op == "greater_equal") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_UGE,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else if (op == "greater_than") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_UGT,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else if (op == "less_than") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_ULT,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else if (op == "is_equal") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_EQ,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else if (op == "is_not_equal") {
            return CmpInst::Create(Instruction::ICmp,
                    ICmpInst::ICMP_NE,
                    l,
                    r,
                    "",
                    context.currentBlock());
        }
        else {
            cout << "Invalid binary operator found." << op << endl;
        }
    }

    return BinaryOperator::Create(instr, l, r, "", context.currentBlock());
}

Value* UnaryOp::codeGen(CodeGenContext &context) {

    Value *v = ref(rrand->codeGen(context), rrand, context);
    if (op == "minus") {
        return Builder.CreateNeg(v);
    }
    else if (op == "not") {
        return Builder.CreateNot(v);
    }
    else {
        cout << "Invalid Unary operator found.";
    }
}

Value* MethodDeclarations::codeGen(CodeGenContext &context) {
  return codeGenChildren(ds, context);
}

Value* ProcedureCall::codeGen(CodeGenContext &context) {
    if (flag == "callout") {
        vector<llvm::Type *> argsType;
        vector<llvm::Value *> Args;
        list<Node *>::iterator it;
        for(it = args.begin() ; it != args.end() ; ++it) {
            argsType.push_back(ref((*it)->codeGen(context), *it, context)->getType());
            Args.push_back(ref((*it)->codeGen(context), *it, context));
        }

        ArrayRef<llvm::Type*> argsRef(argsType);
        ArrayRef<llvm::Value*> argsRef1(Args);

        FunctionType *Ftype = FunctionType::get(Builder.getInt32Ty(), argsRef, false);
        Constant *Func = context.module->getOrInsertFunction(fn_name, Ftype);

        if(!Func) return NULL;
        return Builder.CreateCall(Func, argsRef1);

    } else {
        Function *func = context.module->getFunction(fn_name);

        if(func==NULL) {
            std::cerr<< fn_name <<"Function not declared"<<endl;
            return NULL;
        }

        vector<llvm::Value *> Args;
        list<Node *>::iterator it;
        for(it = args.begin() ; it != args.end() ; ++it) {
            Args.push_back(ref((*it)->codeGen(context), *it, context));
        }
        llvm::ArrayRef<llvm::Value*>  argsRef(Args);
        CallInst *call = NULL;
        call = CallInst::Create(func, argsRef, "", context.currentBlock());
        return call;
    }
}

Value* Block::codeGen(CodeGenContext &context) {
    Value *ret = NULL;
    if(left)
        ret = left->codeGen(context);
    if(right)
        ret = right->codeGen(context);
    return ret;
}

Value* Conditionals::codeGen(CodeGenContext &context) {

    Node *test = ((IFStatement *)ifpart)->test;
    Node* ifbody = ((IFStatement *)ifpart)->body;
    Node* elsebody;
    if(elsepart == NULL) {
        elsebody = new Block(NULL, NULL);
    }
    else {
        elsebody = ((ELSEStatement *)elsepart)->body;
    }
    Value* testGen = ref(test->codeGen(context), test, context);
    Value* compare = Builder.CreateICmpNE(ConstantInt::get(testGen->getType(), 0, true), testGen);
    Function *function = Builder.GetInsertBlock()->getParent();
    BasicBlock* ifBB = BasicBlock::Create(getGlobalContext(), "if", function);
    BasicBlock* elseBB = BasicBlock::Create(getGlobalContext(), "else");
    BasicBlock *MergeBB = BasicBlock::Create(getGlobalContext(), "ifcont");

    bool MergeIt1 = 1;
    Builder.CreateCondBr(compare, ifBB, elseBB);
    Builder.SetInsertPoint(ifBB);
    context.pushBlock(ifBB);
    ((Block *)ifbody)->codeGen(context);
    context.popBlock();

    // check return statement in if block
    if (((Block *)ifbody)->right) {
        list<Node*> statements = ((Statements *)(((Block *)ifbody)->right))->ss;
        list<Node*>::iterator it;
        for(it=statements.begin();it!=statements.end();it++) {
            if ((*it)->class_type == "return") {
                MergeIt1 = 0;
                break;
            }
        }
    }

    if(MergeIt1)
    {
        Builder.CreateBr(MergeBB);
        ifBB = Builder.GetInsertBlock();
    }

    bool MergeIt2 = 1;
    function->getBasicBlockList().push_back(elseBB);
    Builder.SetInsertPoint(elseBB);
    context.pushBlock(elseBB);
    // else part should always be there
    ((Block *)elsebody)->codeGen(context);
    context.popBlock();
    if(((Block *)elsebody)->right) {
        list<Node*> statements = ((Statements *)(((Block *)elsebody)->right))->ss;
        list<Node*>::iterator it;
        for(it=statements.begin();it!=statements.end();it++) {
          if ((*it)->class_type == "return") {
            MergeIt2 = 0;
            break;
          }
        }
    }

    if(MergeIt2)
    {
        Builder.CreateBr(MergeBB);
        elseBB = Builder.GetInsertBlock();
    }

    if(MergeIt1 || MergeIt2)
    {
        function->getBasicBlockList().push_back(MergeBB);
        Builder.SetInsertPoint(MergeBB);
    }
    context.pushBlock(MergeBB);
}

Value* VariableDeclarations::codeGen(CodeGenContext &context) {
    return codeGenChildren(declarations, context);
}

Value* Statements::codeGen(CodeGenContext &context) {
    Value *ret;
    int _count = 0;
    list<Node*>::iterator it;
    for(it=ss.begin();it!=ss.end();it++) {
        ret = (*it)->codeGen(context);
        if((*it)->class_type == "return") {
          break;
        }
        if((*it)->class_type == "if" || (*it)->class_type == "for") {
          _count++;
        }
    }
    while(_count--) {
      context.popBlock();
    }
    return ret;
}

Value* Return::codeGen(CodeGenContext &context) {
    if (value) {
      Value* exp = ref(value->codeGen(context), value, context);
      Value* ret = ReturnInst::Create(getGlobalContext(), exp, context.currentBlock());
    return ret;
    } else {
      Value* ret = Builder.CreateRetVoid();
    return ret;
    }
}

Value* MethodDeclaration::codeGen(CodeGenContext &context) {
    Node* fn_body = body;
    std::vector<Type*> argTypes;
    list<Node*>::iterator it;

    for(it = params.begin() ; it != params.end() ; ++it) {
        argTypes.push_back(typeOf(((FieldDeclaration *)(*it))->decl_type));
    }
    llvm::ArrayRef<llvm::Type*>  argsRef(argTypes);
    FunctionType *ftype = FunctionType::get(typeOf(return_type), argsRef, false);
    Function *function = Function::Create(ftype, GlobalValue::InternalLinkage, fn_name, context.module);
    BasicBlock *bblock = BasicBlock::Create(getGlobalContext(), "entry", function, 0);
    Builder.SetInsertPoint(bblock);
    context.pushBlock(bblock);
    Function::arg_iterator args = function->arg_begin();
    for(it = params.begin() ; it != params.end() ; ++it) {
        Value* left = (*it)->codeGen(context);
        new StoreInst(args++, left, context.currentBlock());
    }
    fn_body->codeGen(context);
    context.popBlock();
    return function;
}
