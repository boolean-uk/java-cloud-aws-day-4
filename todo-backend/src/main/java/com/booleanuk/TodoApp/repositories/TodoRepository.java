package com.booleanuk.TodoApp.repositories;

import com.booleanuk.TodoApp.models.Todo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TodoRepository extends JpaRepository<Todo, Integer> {
}
