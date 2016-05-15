extern crate redis;
extern crate r2d2;
extern crate r2d2_redis;
extern crate router;

use std::collections::HashMap;

use iron::prelude::*;
use iron::status;
use router::Router;

use persistent::Read;

use database::RedisPool;
use scripts::Scripts;

use uuid::Uuid;
use crypto::blake2b::Blake2b;
use crypto::digest::Digest;

// TODO:
// Waitlist +
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
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();

        let result: HashMap<String, String> = scripts["student_schedule"].arg(session).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:0, data:{:?} }}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();
        let subject = router.find("subject").unwrap();
        let section = router.find("section").unwrap();

        let result: i32 = scripts["student_schedule_enlist"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();
        let subject = router.find("subject").unwrap();
        let section = router.find("section").unwrap();

        let result: i32 = scripts["student_schedule_cancel"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
    }
}

pub struct Waitlist;
impl Waitlist{
    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();
        let subject = router.find("subject").unwrap();
        let section = router.find("section").unwrap();

        let result: i32 = scripts["student_waitlist_position"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();
        let subject = router.find("subject").unwrap();
        let section = router.find("section").unwrap();

        let result: i32 = scripts["student_waitlist_enlist"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let session = router.find("session").unwrap();
        let subject = router.find("subject").unwrap();
        let section = router.find("section").unwrap();

        let result: i32 = scripts["student_waitlist_cancel"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
    }
}

pub struct Auth;
impl Auth{
    pub fn post(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let username = router.find("username").unwrap();
        let password = {
            let password = router.find("password").unwrap();
            let mut blake = Blake2b::new(32);
            blake.input_str(&password);
            blake.result_str()
        };
        let session_key = Uuid::new_v4();

        let result: i32 = scripts["auth_login"].arg(username).arg(password).arg(format!("{}",session_key.simple())).invoke(redis_connection).unwrap();
        if result != 0 {
            Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))
        } else {
            Ok(Response::with((status::Ok, format!("{{ result:{}, key:{} }}", result, session_key.simple()))))
        }
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let router = req.extensions.get::<Router>().unwrap();

        let username = router.find("username").unwrap();
        let password = {
            let password = router.find("password").unwrap();
            let mut blake = Blake2b::new(32);
            blake.input_str(&password);
            blake.result_str()
        };
        let number = router.find("student_number").unwrap();

        let result: i32 = scripts["auth_register"].arg(username).arg(password).arg("0").arg(number).invoke(redis_connection).unwrap();
        Ok(Response::with((status::Ok, format!("{{ result:{} }}", result))))

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
