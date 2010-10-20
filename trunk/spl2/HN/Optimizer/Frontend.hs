module HN.Optimizer.Frontend (optimize) where
import HN.Intermediate
import Compiler.Hoopl
import Control.Monad
import HN.Optimizer.Inbound
import HN.Optimizer.Inliner2
import HN.Optimizer.WithGraph

import HN.Optimizer.Visualise

runFB = runF >=> runB

xxx = ["incr", "print", "sum", "filter", "bind", "readnum", "natrec", "_if", "eq", "mod", "mul", "forever", "voidbind", "udp_receive", "time_msec", "udp_send", "udp_connect", "sub", "div", "_or"]

transform tf = withGraph (fromTuple . runSimpleUniqueMonad . runWithFuel infiniteFuel . tf . toTuple) xxx  where
	toTuple agraph = (agraph, undefined, undefined)
	fromTuple (agraph, _, _) = error $ foo $ agraph

optimize :: Definition -> Definition
optimize = transform $ runFB >=> runFB