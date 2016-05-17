extern crate redis;
extern crate r2d2;
extern crate r2d2_redis;
extern crate router;

use std::collections::HashMap;

use iron::prelude::*;
use iron::status;
use router::Router;

use urlencoded::UrlEncodedQuery;

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
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };


        let session = query.get("session").unwrap().get(0).unwrap();

        let result: HashMap<String, String> = scripts["student_schedule"].arg(session.clone()).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":0, \"data\":{:?} }}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["student_schedule_enlist"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["student_schedule_cancel"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }
}

pub struct Waitlist;
impl Waitlist{
    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["student_waitlist_position"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["student_waitlist_enlist"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["student_waitlist_cancel"].arg(session).arg(subject).arg(section).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }
}

pub struct Auth;
impl Auth{
    pub fn post(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };
        //let router = req.extensions.get::<Router>().unwrap();

        let username = query.get("username").unwrap().get(0).unwrap().clone();
        let password = {
            let password = query.get("password").unwrap().get(0).unwrap();
            let mut blake = Blake2b::new(32);
            blake.input_str(&password);
            blake.result_str()
        };
        let session_key = Uuid::new_v4();

        let result: i32 = scripts["auth_login"].arg(username).arg(password).arg(format!("{}",session_key.simple())).invoke(redis_connection).unwrap();
        if result != 0 {
            Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
        } else {
            Ok(Response::with((status::Ok, format!("{{ \"result\":{}, \"key\":\"{}\" }}", result, session_key.simple()))))
        }
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };
        let router = req.extensions.get::<Router>().unwrap();

        let username = query.get("username").unwrap().get(0).unwrap().clone();
        let password = {
            let password = query.get("password").unwrap().get(0).unwrap();
            let mut blake = Blake2b::new(32);
            blake.input_str(&password);
            blake.result_str()
        };
        let number = router.find("student_number").unwrap();

        let result: i32 = scripts["auth_register"].arg(username).arg(password).arg("0").arg(number).invoke(redis_connection).unwrap();
        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }

    pub fn del(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();

        let result: i32 = scripts["auth_logout"].arg(session).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }
}

pub struct Student;
impl Student{
    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let student_number = query.get("student_number").unwrap().get(0).unwrap().clone();
        let first_name = query.get("first_name").unwrap().get(0).unwrap().clone();
        let middle_name = query.get("middle_name").unwrap().get(0).unwrap().clone();
        let last_name = query.get("last_name").unwrap().get(0).unwrap().clone();
        let curriculum = query.get("curriculum").unwrap().get(0).unwrap().clone();
        let standing = query.get("standing").unwrap().get(0).unwrap().clone();
        let max_units = query.get("max_units").unwrap().get(0).unwrap().clone();
        //session student_number first_name middle_name last_name curriculum standing max_units

        let result: i32 = scripts["admin_student_add"]
            .arg(session)
            .arg(student_number)
            .arg(first_name)
            .arg(middle_name)
            .arg(last_name)
            .arg(curriculum)
            .arg(standing)
            .arg(max_units)
            .invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":{} }}", result))))
    }

    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();
        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let session = query.get("session").unwrap().get(0).unwrap().clone();

        let result: HashMap<String, String> = scripts["student_profile"].arg(session).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{{ \"result\":0, \"data\":{:?} }}", result))))
    }
}

pub struct Subject;
impl Subject{
    pub fn get(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let sections = query.get("sections").unwrap().get(0).unwrap().clone();

        let result: HashMap<String, i32> = scripts["subject_slots"].arg(subject).arg(sections).invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("{:?}", result))))
    }

    pub fn put(req: &mut Request) -> IronResult<Response> {
        let redis_connection = &get_db_connection(req) as &redis::Connection;
        let scripts = req.get::<Read<Scripts>>().unwrap();

        let query = match req.get::<UrlEncodedQuery>() {
            Ok(hashmap) => hashmap,
            Err(_) => return Ok(Response::with((status::BadRequest)))
        };

        //  subject section max_slots schedule_set lecture

        let session = query.get("session").unwrap().get(0).unwrap().clone();
        let subject = query.get("subject").unwrap().get(0).unwrap().clone();
        let section = query.get("section").unwrap().get(0).unwrap().clone();
        let max_slots = query.get("max_slots").unwrap().get(0).unwrap().clone();
        //let subject = query.get("session").unwrap().get(0).unwrap().clone();
        let lecture = match query.get("lecture") {
            Some(s) => s.get(0).unwrap().clone(),
            None => "".to_string()
        };

        let result: i32 = scripts["admin_subject_add"]
        .arg(session).arg(subject).arg(section).arg(max_slots).arg(lecture)
        .invoke(redis_connection).unwrap();

        Ok(Response::with((status::Ok, format!("\"result\" :{:?}", result))))
    }
}
