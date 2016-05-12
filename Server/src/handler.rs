extern crate redis;

use iron::prelude::*;
use iron::status;

use persistent::Read;

use database::RedisPool;
use redis::Commands;
use redis::Script;

pub struct Enlisted;
impl Enlisted{
    pub fn get(req: &mut Request) -> IronResult<Response> {
        //Ok(Response::with((status::NotFound, "unimplemented")))

        let redis_pool = req.get::<Read<RedisPool>>().unwrap();
        let redis_connection : &redis::Connection = &*redis_pool.get().unwrap();

        //let n: i64 = redis_connection.incr("counter", 1).unwrap();
        let script = Script::new("
            local c = redis.call(\"INCR\", \"counter\");
            return c/2;
        ");
        let n: i32 = script.arg(1).arg(2).invoke(redis_connection).unwrap();
        //let n = 1;
        Ok(Response::with((status::Ok, format!("{}", n))))
    }

    pub fn put(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Waitlist;
impl Waitlist{
    pub fn get(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn put(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Auth;
impl Auth{
    pub fn post(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Subject;
impl Subject{
    pub fn get(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}
