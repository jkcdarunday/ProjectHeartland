extern crate redis;
extern crate r2d2;
extern crate r2d2_redis;

use std::collections::HashMap;

use iron::prelude::*;
use iron::status;

use persistent::Read;

use database::RedisPool;
use scripts::Scripts;

// TODO:
// Waitlist
// Authentication (Sessions)
// Roles
// TODO_AFTER:
// Loading of schedule of subjects
// Server-side conflict checking for each time period

fn get_db_connection(req: &mut Request) -> r2d2::PooledConnection<r2d2_redis::RedisConnectionManager>{
    req.get::<Read<RedisPool>>().unwrap().get().unwrap()
}

pub struct Enlisted;
impl Enlisted{
    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let result: HashMap<String, String> = scripts["student_schedule"].arg("2012-10053").invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{:?}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let result: i32 = scripts["student_schedule_enlist"].arg("2012-10053").arg("cmsc161").arg("uv-2l").invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let result: i32 = scripts["student_schedule_cancel"].arg("2012-10053").arg("cmsc161").arg("uv-2l").invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{}", result))))
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
    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let result: HashMap<String, i32> = scripts["subject_slots"].arg("cmsc161").invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{:?}", result))))
    }
}
